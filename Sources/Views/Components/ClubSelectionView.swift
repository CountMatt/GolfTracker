//
//  ClubSelectionView.swift
//  GolfTracker
//
//  Created by Matteo Keller on 25.03.2025.
//


// File: Sources/Views/Components/ClubSelectionView.swift
import SwiftUI

struct ClubSelectionView: View {
    @Binding var selectedClub: Club?
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Club.allClubs) { club in
                        Button(action: {
                            selectedClub = club
                        }) {
                            Text(club.name)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedClub?.id == club.id ? Color.green : Color.gray.opacity(0.2))
                                .foregroundColor(selectedClub?.id == club.id ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            if let club = selectedClub {
                Text("Selected: \(club.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Select a club")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}