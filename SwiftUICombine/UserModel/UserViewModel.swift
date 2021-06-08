//
//  UserViewModel.swift
//  SwiftUICombine
//
//  Created by Grigor Keshishyan on 08.06.21.
//

import Foundation
import Combine
import SwiftUI
import Navajo_Swift

class UsserViewModel: ObservableObject {
    //input
    @Published var userName: String = ""
    @Published var password: String = ""
    @Published var passwordAgain: String = ""
    
    //outPut
    @Published var isValid: Bool = false
    private var cancellableSet = Set<AnyCancellable>()
    
    init() {
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellableSet)
    }
    private var isFormValidPublisher: AnyPublisher <Bool, Never> {
        Publishers.CombineLatest(isUserNameValidPublisher, isValidPasswordPublisher)
            
            .map({ isValidUserNAme, isValidPassword in
                return isValidUserNAme && (isValidPassword == .valid)
            })
            .eraseToAnyPublisher()
    }
    
    private var isUserNameValidPublisher: AnyPublisher <Bool, Never> {
        $userName
            ///The debounce statement allows us to tell the system that we want to wait for a pause in the delivery of events, such as when the user stops typing.
            .debounce(for: 0.8, scheduler: RunLoop.main)
            ///removeDuplicates statementwill only publish events if they differ from any previous events. For example, if the user first enters john , then joe , and then john again  , we will only get john once. This helps make our UI more efficient.
            .removeDuplicates()
            .map({ input in
                return input.count >= 3
            })
            .eraseToAnyPublisher()
        //            .assign(to: \.isValid, on: self)
        //            ///The result of this chain of calls is Cancellable , which we can use to cancel processing when needed (useful for long chains). We'll save it (and all the others that we'll create later) in a Set <AnyCancellable> , which we can clear when we deinit  our userViewModel .
        //            .store(in: &cancellableSet)
    }
    private var isValidPasswordPublisher: AnyPublisher <PasswordCheck, Never> {
        Publishers.CombineLatest(isPasswordEmptyPublisher, arePasswordsEqualPublisher)
            .map { passwordIsEmpty, passwordAreEqual in
                if passwordIsEmpty {
                    return .empty
                }
                return .noMatch
            }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordEmptyPublisher: AnyPublisher <Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map({ input in
                return input.isEmpty
            })
            .eraseToAnyPublisher()
    }
    
    private var arePasswordsEqualPublisher: AnyPublisher <Bool, Never> {
        Publishers.CombineLatest($password, $passwordAgain)
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .map({ password, passwordAgain in
                return  password == passwordAgain
            })
            .eraseToAnyPublisher()
    }
    
    private var passwordStrengthPublisher: AnyPublisher <PasswordStrength, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map({ input in
                return Navajo.strength(ofPassword: input)
            })
            .eraseToAnyPublisher()
    }
    
    private var isPasswordStrongEnoughPublisher: AnyPublisher <Bool, Never> {
        passwordStrengthPublisher
            .map { strenght in
                switch strenght {
                case .reasonable, .strong, .veryStrong:
                    return true
                default:
                    return false
                }
            }
            ///In case you're wondering why we have to call eraseToAnyPublisher () at the end of each chain, I explain: this does erase some TYPE, it ensures that we don't get some crazy nested return TYPES and can embed them in any chain.
            .eraseToAnyPublisher()
        
    }
}
