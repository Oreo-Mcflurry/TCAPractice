import ComposableArchitecture
import SwiftUI

// MARK: - State
@ObservableState
struct CounterState: Equatable {
    var count: Int = 0
    var isLoading: Bool = false
}

// MARK: - Action
enum CounterAction: Equatable {
    case incrementButtonTapped
    case decrementButtonTapped
    case resetButtonTapped
    case loadingChanged(Bool)
    case testAction(Int)
}

// MARK: - Reducer
struct CounterReducer: Reducer {
    typealias State = CounterState
    typealias Action = CounterAction
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                state.count += 1
                return .none
                
            case .decrementButtonTapped:
                state.count -= 1
                return .none
                
            case .resetButtonTapped:
                state.count = 0
                return .none
                
            case .loadingChanged(let isLoading):
                state.isLoading = isLoading
                return .none
                
            case .testAction(let value):
                print("Test action received with value: \(value)")
                return .run { send in
                    await send(.loadingChanged(true))
                    // Simulate some asynchronous work
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    await send(.incrementButtonTapped)
                    await send(.loadingChanged(false))
                }
            }
        }
    }
}

// MARK: - View
struct CounterView: View {
    let store: StoreOf<CounterReducer>
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(store.count)")
                .font(.title)
            
            Text("Loading: \(store.isLoading ? "Yes" : "No")")
                .font(.subheadline)
            
            HStack(spacing: 20) {
                Button("Decrement") {
                    store.send(.decrementButtonTapped)
                }
                .buttonStyle(.bordered)
                
                Button("Increment") {
                    store.send(.testAction(1))
                }
                .buttonStyle(.bordered)
            }
            
            Button("Reset") {
                store.send(.resetButtonTapped)
            }
            .buttonStyle(.borderedProminent)
            
            
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    CounterView(
        store: Store(
            initialState: CounterState(),
            reducer: { CounterReducer() }
        )
    )
} 
