//
//  ContentView.swift
//  Timer
//
//  Created by 조영민 on 1/24/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var timeRemaining: Double = 0.0
    @State private var isPlaying: Bool = false
    @State private var totalTime: Double = 0.0
    @State private var rotation: Double = 0.0
    @State private var selectedTime = Time(hours: 0, minutes: 0, seconds: 0)
    @State private var hasBeeped: Bool = false // 비프음 울렸는지 여부

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
                .frame(width: 200, height: 100)
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

            // 타이머 프로그레스 바
            if totalTime > 0 {
                ProgressView(value: totalTime - timeRemaining, total: totalTime)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 20)
                    .animation(.easeInOut(duration: 0.5), value: timeRemaining)
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
                    isPlaying = false
                    timeRemaining = 0
                    totalTime = 0
                    rotation = 0
                    selectedTime = Time(hours: 0, minutes: 0, seconds: 0)
                    hasBeeped = false
                }) {
                    Image(systemName: "forward.fill")
                        .font(.largeTitle)
                }
            }
        }
        .padding(70)
        .onReceive(timer) { _ in
            if isPlaying && timeRemaining > 0 {
                timeRemaining -= 1
                rotation += 360 / totalTime
                hasBeeped = false
            } else if timeRemaining == 0 && !hasBeeped {
                isPlaying = false
                NSSound.beep()
                hasBeeped = true
            }
        }
    }

    // 타이머 시작
    private func startTimer() {
        if !isPlaying {
            if totalTime == 0 {
                let totalSeconds = Double(selectedTime.hours * 3600 + selectedTime.minutes * 60 + selectedTime.seconds)
                if totalSeconds > 0 {
                    totalTime = totalSeconds
                    timeRemaining = totalSeconds
                }
            }
            isPlaying = true
            rotation = 0
        } else {
            isPlaying = false
        }
    }

    // 타이머와 회전을 초기화
    private func resetTimer() {
        isPlaying = false
        timeRemaining = totalTime
        rotation = 0
        hasBeeped = false // 초기화 시 비프음 울림 상태도 초기화
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
