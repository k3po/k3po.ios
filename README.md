# K3PO for iOS

[![Build Status][build-status-image]][build-status]
[![Issue Stats][pull-requests-image]][pull-requests]
[![Issue Stats][issues-closed-image]][issues-closed]

[build-status-image]: https://travis-ci.org/k3po/k3po.ios.svg?branch=develop
[build-status]: https://travis-ci.org/k3po/k3po.ios
[pull-requests-image]: http://www.issuestats.com/github/k3po/k3po.ios/badge/pr
[pull-requests]: http://www.issuestats.com/github/k3po/k3po.ios
[issues-closed-image]: http://www.issuestats.com/github/k3po/k3po.ios/badge/issue
[issues-closed]: http://www.issuestats.com/github/k3po/k3po.ios

Objective-C based Network Protocol Testing Framework

# Building this Project

## Minimum requirements for building the project

* Xcode 5 or higher
* Xcode's Command Line Tools.  From Xcode, install via _Xcode &rarr; Preferences &rarr; Downloads_.
* xctool: ```brew install -v --HEAD xctool```

## Steps for building this project

0. Clone the repo: ```git clone https://github.com/k3po/k3po.ios.git```
0. Go to the cloned directory: ```cd k3po.ios```
0. Build the project: ```xctool -project K3poControl.xcodeproj -scheme Framework```

K3poControl.framework will be available under build/framework folder.

