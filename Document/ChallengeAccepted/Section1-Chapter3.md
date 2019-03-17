## Challenge 1: Create a blackjack card dealer using a publish subject
In the starter project, twist down the playground page and Sources folder in the Project navigator, and select the SupportCode.swift file. Review the helper code for this challenge, including a cards array that contains 52 tuples representing a standard deck of cards, cardString(for:) and point(for:) helper functions, and a HandError enumeration.
In the main playground page, add code right below the comment // Add code to update dealtHand here that will evaluate the result returned from calling points(for:), passing the hand array. If the result is greater than 21, add the error HandError.busted onto the dealtHand. Otherwise, add hand onto dealtHand as a .next event.
Also in the main playground page, add code right after the comment // Add subscription to dealtHand here to subscribe to dealtHand and handle .next
and .error events. For .next events, print a string containing the results returned from calling cardString(for:) and points(for:). For an .error event, just print the error.
The call to deal(_:) currently passes 3, so three cards will be dealt each time you press the Execute Playground button in the bottom left corner of Xcode. See how many times you go bust versus how many times you stay in the game. Are the odds stacked up against you in Vegas or what?
The card emoji characters are pretty small when printed in the console. If you want to be able to make out what cards you were dealt, you can temporarily increase the font size of the Executable Console Output for this challenge. To do so, select Xcode/ Preferences.../Fonts & Colors/Console, select Executable Console Output, and click the T button in the bottom right to change it to a larger font, such as 48.

```swift
example(of: "PublishSubject") {

    let disposeBag = DisposeBag()

    let dealtHand = PublishSubject<[(String, Int)]>()

    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining: UInt32 = 52
        var hand = [(String, Int)]()

        for _ in 0..<cardCount {
            let randomIndex = Int(arc4random_uniform(cardsRemaining))
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }

        // Add code to update dealtHand here
        let currentPoints = points(for: hand)
        if currentPoints > 21 {
            dealtHand.onError(HandError.busted)
        } else {
            dealtHand.onNext(hand)
        }
    }

    // Add subscription to dealtHand here
    dealtHand.subscribe(onNext: { element in
        print(cardString(for: element))
    }, onError: { error in
        print(error)
    }).disposed(by: disposeBag)
    deal(3)
}
```

```
--- Example of: PublishSubject ---
🃖🃆🃒
```

or

```
--- Example of: PublishSubject ---
busted
```

##Challenge 2: Observe and check user session state using a variable
Most apps involve keeping track of a user session, and a variable can come in handy for such a need. You can subscribe to react to changes to the user session such as log in or log out, or just check the current value for one-off needs. In this challenge, you’re going to implement examples of both.
Review the setup code in the starter project. There are a couple enumerations to model UserSession and LoginError, and functions to logInWith(username:password:completion:), logOut(), and performActionRequiringLoggedInUser(_:). There is also a for-in loop that attempts to log in and perform an action using invalid and then valid login credentials.
There are four comments indicating where you should add the necessary code in order to complete this challenge.

```swift 
example(of: "Variable") {

    enum UserSession {

        case loggedIn, loggedOut
    }

    enum LoginError: Error {

        case invalidCredentials
    }

    let disposeBag = DisposeBag()

    // Create userSession Variable of type UserSession with initial value of .loggedOut
    let userSession = Variable<UserSession>(.loggedOut)

    // Subscribe to receive next events from userSession
    userSession.asObservable().subscribe(onNext: {
        print("Login state: \($0)")
    }).disposed(by: disposeBag)

    func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com",
            password == "appleseed"
            else {
                completion(LoginError.invalidCredentials)
                return
        }

        // Update userSession
        userSession.value = .loggedIn
    }

    func logOut() {
        // Update userSession
        userSession.value = .loggedOut
    }

    func performActionRequiringLoggedInUser(_ action: () -> Void) {
        // Ensure that userSession is loggedIn and then execute action()
        guard userSession.value == .loggedIn else { return }
        action()
    }

    for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"

        logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
                print(error!)
                return
            }

            print("User logged in.")
        }

        performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
        }
    }
}
```