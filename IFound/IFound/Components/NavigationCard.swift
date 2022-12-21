//
//  NavigationCard.swift
//  IFound
//
//  Created by Edgar Vildt on 20.12.2022.
//

import SwiftUI

struct NavigationCard: View {
    
    var sysIcon: String
    var heading: String
    var explanation: String
    var destination: AnyView
    
    var body: some View {
        
            NavigationLink(destination: destination){
                HStack{
                    Spacer()
                    VStack{
                        HStack{
                            Text(heading)
                                .font(.largeTitle)
                                .padding([.top, .leading])
                            Spacer()
                        } // HStack
                        HStack{
                            Text(explanation)
                                .font(.body)
                                .padding([.leading, .bottom])
                            Spacer()
                        } // HStack
                    } // VStack
                    Spacer()
                    Image(systemName: sysIcon).font(.title)
                    Spacer()

                } // HStack
                .background(.orange)
                .cornerRadius(15)
                .padding([.leading, .bottom, .trailing])
                .shadow(radius: 5)
            }
        
        
    } // View
}

struct NavigationCard_Previews: PreviewProvider {
    static var previews: some View {
        NavigationCard(
            sysIcon: "figure.hiking",
            heading: "Heading",
            explanation: "Explanation",
            destination: AnyView(ActivityView())
        )
    }
}
