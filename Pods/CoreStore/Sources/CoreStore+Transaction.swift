//
//  CoreStore+Transaction.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation


// MARK: - CoreStore

@available(*, deprecated, message: "Call methods directly from the DataStack instead")
extension CoreStore {
    
    /**
     Using the `CoreStoreDefaults.dataStack`, performs a transaction asynchronously where `NSManagedObject` or `CoreStoreObject` creates, updates, and deletes can be made. The changes are commited automatically after the `task` closure returns. On success, the value returned from closure will be the wrapped as `.success(T)` in the `completion`'s `Result<T>`. Any errors thrown from inside the `task` will be reported as `.failure(CoreStoreError)`. To cancel/rollback changes, call `try transaction.cancel()`, which throws a `CoreStoreError.userCancelled`.
     
     - parameter task: the asynchronous closure where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     - parameter completion: the closure executed after the save completes. The `Result` argument of the closure will either wrap the return value of `task`, or any uncaught errors thrown from within `task`. Cancelled `task`s will be indicated by `.failure(error: CoreStoreError.userCancelled)`. Custom errors thrown by the user will be wrapped in `CoreStoreError.userError(error: Error)`.
     */
    public static func perform<T>(asynchronous task: @escaping (_ transaction: AsynchronousDataTransaction) throws -> T, completion: @escaping (AsynchronousDataTransaction.Result<T>) -> Void) {
        
        CoreStoreDefaults.dataStack.perform(asynchronous: task, completion: completion)
    }
    
    /**
     Using the `CoreStoreDefaults.dataStack`, performs a transaction asynchronously where `NSManagedObject` or `CoreStoreObject` creates, updates, and deletes can be made. The changes are commited automatically after the `task` closure returns. On success, the value returned from closure will be the argument of the `success` closure. Any errors thrown from inside the `task` will be wrapped in a `CoreStoreError` and reported in the `failure` closure. To cancel/rollback changes, call `try transaction.cancel()`, which throws a `CoreStoreError.userCancelled`.
     
     - parameter task: the asynchronous closure where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     - parameter success: the closure executed after the save succeeds. The `T` argument of the closure will be the value returned from `task`.
     - parameter failure: the closure executed if the save fails or if any errors are thrown within `task`. Cancelled `task`s will be indicated by `CoreStoreError.userCancelled`. Custom errors thrown by the user will be wrapped in `CoreStoreError.userError(error: Error)`.
     */
    public static func perform<T>(asynchronous task: @escaping (_ transaction: AsynchronousDataTransaction) throws -> T, success: @escaping (T) -> Void, failure: @escaping (CoreStoreError) -> Void) {
        
        CoreStoreDefaults.dataStack.perform(asynchronous: task, success: success, failure: failure)
    }
    
    /**
     Using the `CoreStoreDefaults.dataStack`, performs a transaction synchronously where `NSManagedObject` or `CoreStoreObject` creates, updates, and deletes can be made. The changes are commited automatically after the `task` closure returns. On success, the value returned from closure will be the return value of `perform(synchronous:)`. Any errors thrown from inside the `task` will be thrown from `perform(synchronous:)`. To cancel/rollback changes, call `try transaction.cancel()`, which throws a `CoreStoreError.userCancelled`.
     
     - parameter task: the synchronous non-escaping closure where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     - parameter waitForAllObservers: When `true`, this method waits for all observers to be notified of the changes before returning. This results in more predictable data update order, but may risk triggering deadlocks. When `false`, this method does not wait for observers to be notified of the changes before returning. This results in lower risk for deadlocks, but the updated data may not have been propagated to the `DataStack` after returning. Defaults to `true`.
     - throws: a `CoreStoreError` value indicating the failure. Cancelled `task`s will be indicated by `CoreStoreError.userCancelled`. Custom errors thrown by the user will be wrapped in `CoreStoreError.userError(error: Error)`.
     - returns: the value returned from `task`
     */
    public static func perform<T>(synchronous task: ((_ transaction: SynchronousDataTransaction) throws -> T), waitForAllObservers: Bool = true) throws -> T {
        
        return try CoreStoreDefaults.dataStack.perform(synchronous: task, waitForAllObservers: waitForAllObservers)
    }
    
    /**
     Using the `CoreStoreDefaults.dataStack`, begins a non-contiguous transaction where `NSManagedObject` or `CoreStoreObject` creates, updates, and deletes can be made. This is useful for making temporary changes, such as partially filled forms.
     
     - prameter supportsUndo: `undo()`, `redo()`, and `rollback()` methods are only available when this parameter is `true`, otherwise those method will raise an exception. Defaults to `false`. Note that turning on Undo support may heavily impact performance especially on iOS or watchOS where memory is limited.
     - returns: a `UnsafeDataTransaction` instance where creates, updates, and deletes can be made.
     */
    public static func beginUnsafe(supportsUndo: Bool = false) -> UnsafeDataTransaction {
        
        return CoreStoreDefaults.dataStack.beginUnsafe(supportsUndo: supportsUndo)
    }
    
    /**
     Refreshes all registered objects `NSManagedObject`s or `CoreStoreObject`s in the `CoreStoreDefaults.dataStack`.
     */
    public static func refreshAndMergeAllObjects() {
        
        CoreStoreDefaults.dataStack.refreshAndMergeAllObjects()
    }
}
