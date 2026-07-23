//
//  Discont_AppTaskApp.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 15/07/2026.
//

import SwiftUI

@main
struct Discont_AppTaskApp: App {
    
    let cardViewModel = CardSelectionView.ViewModel(service: FetchItemsService())
    
    var body: some Scene {
        WindowGroup {
            CardSelectionView(viewModel: cardViewModel)
        }
    }
}
