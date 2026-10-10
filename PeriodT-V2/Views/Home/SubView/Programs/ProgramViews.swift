//
//  ProgramViews.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 12/9/2026.
//

import SwiftUI

/// "My Programs" section: heading plus a horizontal scroll of program cards.
struct ProgramViews: View {
    //MARK: DUMMY VARIABLES FOR PROGRAMS
    let programs: [ExerciseProgram]
//    var exerciseData: ExerciseMockData

    //MARK: Formatting
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing:1){
                VStack(alignment: .leading) {
                    Text("My Programs")
                        .font(Font.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(CoreColor.primary)
                        
                    Text("Here are your assigned workouts:")
                        .font(.title3)
                        .foregroundStyle(CoreColor.primary)
                    
                }
                .padding(.horizontal,22)

                
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(){
                        Spacer()
                            .frame(width: 20)
                        ForEach(programs.prefix(5)) { program in
                            ProgramCard(program: program)
                            
                        }
                        
                    }
                }
            }
        }

    }

}

#Preview {
    ProgramViews(programs: [])
}
