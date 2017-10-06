# MYPassthrough

[![Platform](https://img.shields.io/cocoapods/p/MYPassthrough.svg)](https://github.com/PetecOvod/MYPassthrough)
[![CocoaPods](https://img.shields.io/cocoapods/v/MYPassthrough.svg)](http://cocoadocs.org/docsets/MYPassthrough)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/PetecOvod/MYPassthrough)
[![License](http://img.shields.io/cocoapods/l/MYPassthrough.svg)](https://raw.githubusercontent.com/PetecOvod/MYPassthrough/master/LICENSE)

MYPassthrough helps you to guide the user through your application, step by step.
With the help of this framework, it will be easier for you to solve such tasks as guide, tutorials, help, onboarding, etc.

## Features

- [x] Easy to use. Just a few lines of code to start.
- [x] Easy to customize. Flexible configuration system.
- [x] Easy to rotate. Customize the view separately for each orientation
- [x] Easy to control via Handles

## Preview

<img src="https://raw.githubusercontent.com/PetecOvod/ReadmeFiles/d8c0be43e1923bc9733607468e447568f06aac65/MYPassthrough/iOS_Example.gif" width="285"/>

## Installation

- Add the following to your [`Podfile`](http://cocoapods.org/) and run `pod install`
```ruby
pod 'MYPassthrough'
```
- or add the following to your [`Cartfile`](https://github.com/Carthage/Carthage) and run `carthage update`
```
github "PetecOvod/MYPassthrough"
```
- or clone as a git submodule

## Code Example

Four easy steps to get started.
The first is to describe the text you want to show

```swift
let labelDescriptor = LabelDescriptor(for: "From right")
labelDescriptor.position = .right
```

Then describe the rect or view and set labelDescriptor to it.

```swift
let holeDescriptor = HoleDescriptor(frame: exampleRect, type: .circle)
holeDescriptor.labelDescriptor = labelDescriptor
```
or

```swift
let holeViewDescriptor = HoleViewDescriptor(view: exampleView, type: .circle)
holeViewDescriptor.labelDescriptor = labelDescriptor
```

Now create task

```swift
let task = PassthroughTask(with: [holeViewDescriptor])
```

and display.

```swift
PassthroughManager.shared.display(tasks: [task])
```

And of course you have many properties for configuration.
Inside this repository you can try `iOS Example` target with an example of using part of them

## Contributing

Bug reports, issues and pull requests are welcome.

## License

MYPassthrough is released under the MIT license. See LICENSE for details.
