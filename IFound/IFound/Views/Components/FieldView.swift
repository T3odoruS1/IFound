//
//  FieldView.swift
//  IFound
//
//  Created by Edgar Vildt on 15.01.2023.
//

import SwiftUI

struct FieldView: View {
	
	@Binding var fieldValue: String
	var placeHolderText: String
	
	var body: some View{
		VStack{
			//			HStack(alignment: .bottom){
			//				Text("\(upperText)")
			//					.font(.title3)
			//					.fontWeight(.semibold)
			//					.multilineTextAlignment(.leading)
			//					.padding([.leading, .trailing])
			//				Spacer()
			//			}
			TextField("", text: $fieldValue)
				.padding([.bottom, .trailing, .leading])
				.textFieldStyle(.plain)
				.font(Font.title3.bold())
				.offset(y:17)
				.placeholder(when: fieldValue.isEmpty, placeholder: {
					Text(placeHolderText)
						.fontWeight(.bold)
						.padding([.top, .leading])
						.font(Font.title3.bold())
						.offset(y:17)
				})
			Rectangle ()
				.frame (minWidth: 350, minHeight: 3, maxHeight: 3)
				.padding([.leading, .trailing, .bottom])
				.foregroundColor (.orange)
			
		}
	}
	
	
}

struct Field_Previews: PreviewProvider {
	static var previews: some View {
		FieldView(fieldValue: .constant(""), placeHolderText: "Enter your email")
	}
}

extension View {
	func placeholder<Content: View> (
		when shouldShow: Bool,
		alignment: Alignment = .leading,
		@ViewBuilder placeholder: () -> Content) -> some View {
			ZStack (alignment: alignment) {
				placeholder().opacity(shouldShow ? 0.75 : 0).offset(y:-17)
				
				self
			}
			
		}
}
