//
//  GroceryStoreView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/3/25.
//

import SwiftUI
import MapKit

struct GroceryStoreView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    
    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection) {
//            Marker("My Location", systemImage: "paperplane", coordinate: .userLocation)
//                .tint(.blue)
            // TODO: get UserAnnotation() instead, same yt channel
            
            Annotation("My Location", coordinate: .userLocation) {
                ZStack {
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.blue.opacity(0.25))
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.blue)
                }
            }
            
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
        .onAppear() {
            Task {
                await searchStores()
            }
        }
        .onChange(of: mapSelection, { oldValue, newValue in
            showDetails = newValue != nil
        })
        .sheet(isPresented: $showDetails, content: {
            LocationDetailsView(mapSelection: $mapSelection, show: $showDetails, getDirections: $getDirections)
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
        request.region = .userRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 39.9525, longitude: -75.1652)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}

#Preview {
    GroceryStoreView()
}
