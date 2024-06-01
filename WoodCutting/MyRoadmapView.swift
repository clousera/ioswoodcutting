//
//  RoadmapView.swift
//  WoodCutting
//
//  Created by Amanada Clouser on 5/31/24.
//

import SwiftUI
import Roadmap


struct MyRoadmapView: View {
  
  let configuration = RoadmapConfiguration(
      roadmapJSONURL: URL(string: "https://simplejsoncms.com/api/3w9bhpxxtjj")!,
      voter: FeatureVoterTallyAPI(), style: RoadmapTemplate.technical.style

  )
  
    var body: some View {
      NavigationStack {
        RoadmapView(configuration: configuration)
      }
      
    }
}

struct MyRoadmapView_Previews: PreviewProvider {

  static var previews: some View {
    MyRoadmapView()
  }
}
