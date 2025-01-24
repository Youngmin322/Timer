//
//  ContentView.swift
//  Timer
//
//  Created by 조영민 on 1/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var timeRemaining: Double = 0.0
    @State private var isPlaying: Bool = false
    @State private var totalTime: Double = 0.0
    @State private var rotation: Double = 0.0
    @State private var selectedTime = Time(hours: 0, minutes: 0, seconds: 0)

    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    struct Time {
        var hours: Int
        var minutes: Int
        var seconds: Int
    }

    var body: some View {
        VStack(spacing: 20) {
            Image("Recode")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 200)
                .rotationEffect(.degrees(rotation))
                .animation(isPlaying ? .linear(duration: timeRemaining).repeatCount(1, autoreverses: false) : .default, value: rotation)

            // 타이머 Picker hours, minutes, seconds
            HStack {
                Picker("Hour", selection: $selectedTime.hours) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text("\(hour)시")
                    }
                }

                Picker("Minute", selection: $selectedTime.minutes) {
                    ForEach(0..<60, id: \.self) { minute in
                        Text("\(minute)분")
                    }
                }

                Picker("Second", selection: $selectedTime.seconds) {
                    ForEach(0..<60, id: \.self) { second in
                        Text("\(second)초")
                    }
                }
            }
            .labelsHidden()

            // 타이머 카운팅
            Text(formatTime(timeRemaining))
                .font(.largeTitle)
                .bold()
                .foregroundStyle(timeRemaining <= 5 ? .red : .white)

            // 타이머 슬라이더
            VStack {
                Slider(value: Binding(
                    get: { totalTime - timeRemaining }, // 전체 시간 - 남은 시간
                    set: { newValue in
                        timeRemaining = totalTime - newValue
                    }
                ), in: 0...totalTime) // 슬라이더의 최소값...최대값
                .animation(.easeInOut, value: timeRemaining)

                HStack {
                    Text(formatTime(totalTime - timeRemaining))
                    Spacer()
                    Text(formatTime(timeRemaining))
                }
            }

            // Control buttons
            HStack(spacing: 40) {
                Button(action: {
                    resetTimer()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.largeTitle)
                }

                Button(action: {
                    startTimer()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                }

                Button(action: {
                    resetTimer()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.largeTitle)
                }
            }
        }
        .padding(40)
        .onReceive(timer) { _ in
            if isPlaying && timeRemaining > 0 { // 현재 재생 중인지와 남은 시간이 0보다 큰지 확인
                timeRemaining -= 1
                rotation += 360 / totalTime // 전체 시간에 비례해서 회전
            } else {
                isPlaying = false
            }
        }
    }

    // 타이머 시작
    private func startTimer() {
        if !isPlaying {
            let totalSeconds = Double(selectedTime.hours * 3600 + selectedTime.minutes * 60 + selectedTime.seconds)
            if totalSeconds > 0 {
                totalTime = totalSeconds // 총 시간 설정
                timeRemaining = totalSeconds // 남은 시간을 총 시간으로 초기화
                isPlaying = true
                rotation = 0
            }
        } else {
            isPlaying = false
        }
    }

    // 타이머와 회전을 초기화
    private func resetTimer() {
        isPlaying = false
        timeRemaining = totalTime
        rotation = 0
    }

    // HH:MM:SS 형식으로 포맷
    private func formatTime(_ time: Double) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    ContentView()
}
