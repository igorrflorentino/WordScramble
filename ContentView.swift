//
//  ContentView.swift
//  WordScramble
//
//  Created by Igor Florentino on 04/03/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var newWord = ""
    @State private var rootWord = ""
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var score = 0
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("insert the word here", text: $newWord)
                        .onSubmit(addNewWord)
                        .textInputAutocapitalization(.never)
                    if newWord.trimmingCharacters(in: .whitespacesAndNewlines).count <= 3 && newWord.trimmingCharacters(in: .whitespacesAndNewlines).count > 0{
                        Text("word is to short")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                Section{
                    ForEach(usedWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: startGame) {
                        Text("Restart")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Text("Score: \(score)")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .font(.title)
            }
            .onAppear(perform: startGame)
            .navigationTitle(rootWord)
            .alert(alertTitle, isPresented: $showAlert){
                Button("OK"){}
            } message: {
                Text(alertMessage)
            }
        }

    }
    func addNewWord(){
        let wordToAdd = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard wordToAdd.count > 3 else {return}
        guard isReal(wordToAdd) else {
            makeErrorAlert(title: "not real", message: "must be real")
            return
        }
        guard isOriginal(wordToAdd) else {
            makeErrorAlert(title: "not original", message: "must be original")
            return
        }
        guard isPossible(wordToAdd) else {
            makeErrorAlert(title: "not possible", message: "must be possible")
            return
        }
        withAnimation{
            usedWords.insert(wordToAdd, at: 0)
        }
        score += wordToAdd.count
        newWord = ""
    }
    
    func startGame() {
        usedWords = [String]()
        newWord = ""
        score = 0
        if let startFileURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startFileContent = try? String.init(contentsOf: startFileURL){
                let startFileComponents = startFileContent.components(separatedBy: .newlines)
                let startWord = startFileComponents.randomElement() ?? "picabu"
                rootWord = startWord
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(_ word: String) -> Bool{
        !usedWords.contains(word) || (word != rootWord)
    }
    
    func isPossible(_ word: String) -> Bool{
        var letterCount = [Character:Int]()
        for letter in rootWord {
            letterCount[letter, default:0] += 1
        }
        for letter in word{
            if let count = letterCount[letter], count > 0{
                letterCount[letter]! -= 1
            }else{
                return false
            }
        }
        return true
    }
    
    func isReal(_ word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: newWord.utf16.count)
        let mispellings = checker.rangeOfMisspelledWord(in: newWord, range: range, startingAt: 0, wrap: false, language: "en")
        return mispellings.location == NSNotFound
    }
    
    func makeErrorAlert(title: String, message: String){
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    ContentView()
}
