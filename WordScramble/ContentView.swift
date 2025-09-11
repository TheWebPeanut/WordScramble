//
//  ContentView.swift
//  WordScramble
//
//  Created by Elenes Praget, Emilio on 06.09.25.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var wordWasPassed = false
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
                Section {
                    Text("\(score)")
                        .listRowInsets(EdgeInsets.init(top: 20, leading: 170, bottom: 20, trailing: 0))
                        .bold()
                        .font(.system(size: 30))
                } header: { Text("Score") }
                    
            }
            .navigationTitle(rootWord)
            .onSubmit {
                addNewWord()
                calculateScore()
            }
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                Button("Restart") {
                    startGame()
                }
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already.", message: "Be more original.")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not real", message: "That word isn't in the real English dictionary.")
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word too short", message: "Please use words that are longer than 3 letters.")
            return
        }
        
        guard isNotTheStartWord(word: answer) else {
            wordError(title: "Same word as the start word", message: "That's the same word as \(rootWord). Think harder.")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        wordWasPassed = true
    }
    
    func calculateScore() {
        
        guard wordWasPassed else { return }
        
        if newWord.count > 5 {
            score += 3
        } else if newWord.count > 4 {
            score += 2
        } else {
            score += 1
        }
        
        newWord = ""
        
        if usedWords.count.isMultiple(of: 3) {
            score += 3
        }
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isLongEnough(word: String) -> Bool {
        word.count >= 3
    }
    
    func isNotTheStartWord(word: String) -> Bool {
        word != rootWord
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func hasLogged3Words() -> Bool {
        usedWords.count < 3
    }
}

#Preview {
    ContentView()
}
