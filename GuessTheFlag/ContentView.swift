//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Brandon Barros on 5/3/20.
//  Copyright © 2020 Brandon Barros. All rights reserved.
//

import SwiftUI


struct SpinModifier: ViewModifier {
    let amount: Double
    
    func body(content: Content) -> some View {
        content.rotation3DEffect(.degrees(amount), axis: (x:0, y:1, z:0))
    }
}

extension AnyTransition {
    static var spin: AnyTransition {
        .modifier(active: SpinModifier(amount: 360), identity: SpinModifier(amount: 0))
    }
}

struct FlagImage: View {
    var countries: [String]
    var number: Int
    var body: some View {
        
        Image(self.countries[number]).renderingMode(.original)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
            .shadow(color: .black, radius: 2)
            
    }
}


struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0 ... 2)
    
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var currentScore = 0
    @State private var totalQuestions = 0
    @State private var message = ""
    @State private var spin = 0.0
    @State private var correct = false
    @State private var incorrect = false
    @State private var opacity = 0.25
    @State private var rotate = 0.0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.black, .blue]), startPoint: .bottom, endPoint: .top).edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                VStack {
                    Text("Tap the flag of ...")
                        .foregroundColor(.white)
                    
                    Text(countries[correctAnswer])
                        .fontWeight(.black)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                
                ForEach(0 ..< 3) { number in
                    Button(action: {
                        if (number == self.correctAnswer) {
                            self.spin = 360
                            self.opacity = 0.25
                            self.correct = true
                        } else {
                            self.rotate = 360
                            self.incorrect = true
                        }
                        self.flagTapped(select: number)
                    }) {
                        FlagImage(countries: self.countries, number: number)
                    }
                    .rotation3DEffect(.degrees((number == self.correctAnswer) ? self.spin: 0), axis: (x:0, y:1, z:0))
                    .animation(self.correct ? .default: nil)
                    .opacity(((number != self.correctAnswer) && (self.correct)) ? self.opacity: 1)
                    .animation(.default)
                    .rotationEffect(.degrees(self.rotate))
                    .animation(self.incorrect ? .default : nil)
                }
                
                Text("Score: \(currentScore) out of \(totalQuestions)")
                    .foregroundColor(.white)
                    
                Spacer()
            }
        }
        .alert(isPresented: $showingScore) {
            Alert(title: Text(self.scoreTitle), message: Text(message), dismissButton: .default(Text("Continue")) {
                self.askQuestion()
            })
        }
    }
    
    
    func flagTapped(select: Int) {
        if (select == correctAnswer) {
            scoreTitle = "Correct!"
            currentScore += 1
            message = "Great job! Your current score is \(currentScore)"
        } else {
            scoreTitle = "Incorrect"
            message = "You chose the flag for: \(countries[select])"
        }
        
        showingScore = true
        totalQuestions += 1
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        spin = 0
        correct = false
        incorrect = false
        rotate = 0
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
