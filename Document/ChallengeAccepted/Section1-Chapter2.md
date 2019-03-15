## Challenge 1: Perform side effects

In the never operator example earlier, nothing printed out. That was before you were adding your subscriptions to dispose bags, but if you had added it to one, you would’ve been able to print out a message in subscribe’s onDisposed handler. There is another useful operator for when you want to do some side work that doesn’t affect the observable you’re working with.

The do operator allows you to insert side effects; that is, handlers to do things that will not change the emitted event in any way. do will just pass the event through to the next operator in the chain. do also includes an onSubscribe handler, something that subscribe does not.

The method for using the do operator is do(onNext:onError:onCompleted:onSubscribe:onDispose) and you can provide handlers for any or all of these events. Use Xcode’s autocompletion to get the closure parameters for each of the events.

To complete this challenge, insert the do operator in the never example using the onSubscribe handler. Feel free to include any of the other handlers if you’d like; they work just like subscribe’s handlers do.

And while you’re at it, create a dispose bag and add the subscription to it.
Don't forget you can always peek into the finished challenge playground for "inspiration."

```swift
example(of: "Challenge 1") {
    let observable = Observable<Any>.never()
    let bag = DisposeBag()
    observable
        .do(onSubscribe: { print("Do onSubscribe") },
            onSubscribed: { print("Do onSubscribed") },
            onDispose: { print("Do onDispose") })
        .subscribe(onDisposed: { print("Subscribe onDisposed") })
        .disposed(by: bag)
}
```

```
--- Example of: Challenge 1 ---
Do onSubscribe
Do onSubscribed
Do onDispose
Subscribe onDisposed
```

## Challenge 2: Print debug info

Performing side effects is one way to help debug your Rx code. But it turns out that there’s even a better utility for that purpose: the debug operator, which will print information about every event for an observable. It has several optional parameters, perhaps the most useful being that you can include an identifier string that will be printed on each line. In complex Rx chains, where you might add debug calls in multiple places, this can really help differentiate the source of each printout.

Continuing to work in the playground from the previous challenge, complete this challenge by replacing the use of the do operator with debug and provide a string identifier to it as a parameter. Observe the debug output in Xcode's console.

```swift
example(of: "Challenge 2") {
    let observable = Observable<Any>.never()
    let bag = DisposeBag()
    observable.debug("Debug", trimOutput: true)
        .subscribe(onDisposed: { print("Subscribe onDisposed") })
        .disposed(by: bag)
}
```

```
--- Example of: Challenge 2 ---
2019-03-15 09:37:53.985: Debug -> subscribed
2019-03-15 09:37:53.987: Debug -> isDisposed
Subscribe onDisposed
```



