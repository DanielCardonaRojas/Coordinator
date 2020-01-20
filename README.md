# Coordinator

![](https://github.com/DanielCardonaRojas/Coordinator/workflows/Coordinator/badge.svg)

A class based implementation of the coordinator pattern.

https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps

As much as we all I love protocol oriented programming, I think this particular pattern is more flexible as a class based implementation. 

## Features

- Early exit on coordinator flows.
- Less boilerplate than protocol based implementation. (Don't have to explicitly add a navigationController property to all coordinators e.g)
-  Present coordinators modally or pushing
- Observe when a child coordinator starts or terminates. (CoordinatorDelegate)
