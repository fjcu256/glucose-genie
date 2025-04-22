//
//  GroceryStoreView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/3/25.
//

import SwiftUI
import MapKit

struct GroceryStoreView: View {
    @StateObject private var viewModel = GroceryStoreViewModel()
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    
    var body: some View {
        Group {
                if viewModel.isLocationAuthorized {
                    mapViewContent // show map when authorized
                } else {
                    ProgressView("Waiting for location permission...")
                        .padding()
                }
            }
    }
    
    private var mapViewContent: some View {
        Map(position: $viewModel.cameraPosition, selection: $mapSelection) {
            //user location
            UserAnnotation()
            
            //populate map with markers for stores
            ForEach(results, id: \.self) { item in
                let placemark = item.placemark
                Marker(placemark.name ?? "", coordinate: placemark.coordinate)
            }
        }
        .overlay(alignment: .bottom) {
            Button(action: {
                Task {
                    await searchStores()
                }
            }, label: {
                Text("Search for stores")
            })
            .font(.headline)
            .padding(12)
            .padding()
            .shadow(radius: 10)
            .buttonStyle(.borderedProminent)
        }
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapUserLocationButton()
        }
        .onChange(of: mapSelection, { oldValue, newValue in
            showDetails = newValue != nil
        })
        //pop up window when clicking on store marker
        .sheet(isPresented: $showDetails, content: {
            LocationDetailsView(mapSelection: $mapSelection, show: $showDetails)
                .presentationDetents([.height(340)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
        })
    }
}

extension GroceryStoreView {
    func searchStores() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Grocery Stores"
        request.region = viewModel.getRegion()
        
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
}

#Preview {
    GroceryStoreView()
}
