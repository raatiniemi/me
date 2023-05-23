+++
title = "Use case driven development"
date = "2023-05-23"
+++

<!--Give an example of a use case, perhaps the origin of the term, etc.

Discuss a typical project with several services, how they can be difficult to test, large constructors, etc.

Describe how one can move from services to use cases, each public method in the service can be extracted to their own use case-->

When building a web or backend application, a common architecture is to separate the application logic into one or more services, usually around a specific entity, e.g. `UserService`.

A downside with this architecture, if one is not careful, is that each service can grow rather large, both in terms of lines of code as well as its public API, which will affect its maintainability and testability.

The approach I use when addressing this is to, instead of separating the logic into services, separate the logic into specific use cases.

A use case is a specific action or functionality the system performs, breaking down service functionality into individual use cases improves separation of concerns and testability.

Let's continue using the `UserService` as example to illustrate the differences between the architectures.

```kotlin
class UserService(
    private val users: Users,
    private val emailService: EmailService
) {
    fun getAllUsers(): Result<List<User>> { /* ... */ }
    fun getUserById(id: String): Result<User?> { /* ... */ }
    fun createUser(newUser: NewUser): Result<User> { /* ... */ }
}
```

Here we have three public methods that will get all the users, get user by id, and create a new user. One thing that might not be obvious from this example is that not all methods use all constructor arguments, i.e. the `createUser`-method is the only one using the `emailService`. Constructor bloat is rather common and will affect the testability of the service.

These methods are essentially three separate use cases, as they each represents a specific action or behavior, i.e. instead of encapsulating the logic into one class we should separate it into three separate classes.

```kotlin
class GetAllUsers(private val users: Users) {
    // Use of the invoke operator, allows the caller to use the method syntax
    // when invoking the method on the instance, i.e. `getAllUsers()`.
    operator fun invoke(): Result<List<User>> { /* ... */ }
}

class GetUsersById(private val users: Users) {
    operator fun invoke(id: String): Result<User?> { /* ... */ }
}

class CreateUser(
    private val users: Users,
    private val emailService: EmailService
) {
    operator fun invoke(newUser: NewUser): Result<User> { /* ... */ }
}
```

By separating the service into three use cases, we can reduce the complexity and improve testability.
