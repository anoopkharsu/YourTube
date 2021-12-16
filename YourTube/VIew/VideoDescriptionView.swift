//
//  VideoDescriptionView.swift
//  YourTube
//
//  Created by Anoop Kharsu on 17/11/21.
//

import SwiftUI
import GoogleAPIClientForREST

struct TextWithId: Identifiable {
    var id = UUID()
    let text: String
    let color: Bool
}

struct VideoDescriptionView: View {
    let item: GTLRYouTube_Video
    let channelImageData: Data
    let date: GTLRDateTime
    let likes: String
    let viewCounts: Int
    let dissmiss: () -> Void
    var stringDate: String {
        let date = date.date.formatted(date: .abbreviated, time: .omitted).split(separator: ",")[0]
        return "\(date)"
    }
    var stringYear: String {
        let year = Calendar.current.component(.year, from: date.date)
        return "\(year)"
    }
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Description").shadow(color: .clear, radius: 0, x: 0, y: 0)
                    Spacer()
                    Button {
                        dissmiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .padding()
            }
            .background {
               Rectangle()
                    .fill(.background)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
            }
            ScrollView{
                VStack {
                    HStack {
                        Text(item.snippet?.title ?? "")
                            .font(.headline)
                        Spacer(minLength: 0)
                    }
                    
                    HStack {
                        Image(uiImage: UIImage(data: channelImageData)!)
                            .resizable()
                            .frame(width: 40, height: 40, alignment: .center)
                            .cornerRadius(20)
                            .clipped()
                        
                        Text(item.snippet?.channelTitle ?? "")
                            .font(.subheadline)
                            .fontWeight(.light)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        VStack {
                            Text(likes)
                                .font(.headline)
                            Text("Likes")
                                .font(.footnote)
                                .foregroundColor(Color.init(uiColor: .secondaryLabel))
                        }
                        Spacer()
                        VStack {
                            Text("\(viewCounts)")
                                .font(.headline)
                            Text("Views")
                                .font(.footnote)
                                .foregroundColor(Color.init(uiColor: .secondaryLabel))
                        }
                        Spacer()
                        VStack {
                            Text(stringDate)
                                .font(.headline)
                            Text(stringYear)
                                .font(.footnote)
                                .foregroundColor(Color.init(uiColor: .secondaryLabel))
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    Divider()
                        .padding(.bottom, 8.0)
                    
                    Text(LocalizedStringKey(item.snippet?.descriptionProperty ?? ""))
                        .font(.subheadline)
                    Spacer(minLength: 50)
                }
                .padding()
            }
            
        }
        
    }
}



//
//struct SenderReciverUI1: View {
//@State private var message = "Hello, www.google.com. this is just testing for hyperlinks, check this out our website https://www.apple.in thank you."
//@State private var textStyle = UIFont.TextStyle.body
//
//var body: some View {
//    Group {
//        HStack(alignment: .bottom){
//            VStack(alignment: .leading,spacing:5) {
//                HStack(alignment: .bottom) {
//                    TextView(text: $message, textStyle: $textStyle)
//                        .foregroundColor(.white)
//                        .padding(10)
//                        .cornerRadius(10.0)
//                   }
//              }
//             Spacer()
//        }.padding(.vertical,5)
//        .padding()
//       }
//     }
// }
//
//struct TextView: UIViewRepresentable {
//
//    @Binding var text: String
//    @Binding var textStyle: UIFont.TextStyle
//
//    func makeUIView(context: Context) -> UITextView {
//        let textView = UITextView()
//
//        textView.delegate = context.coordinator
//        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
//        textView.autocapitalizationType = .sentences
//        textView.isSelectable = true
//        textView.isUserInteractionEnabled = true
//        textView.isEditable = false
//        textView.dataDetectorTypes = .link
//
//        return textView
//    }
//
//    func updateUIView(_ uiView: UITextView, context: Context) {
//        uiView.text = text
//        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator($text)
//    }
//
//    class Coordinator: NSObject, UITextViewDelegate {
//        var text: Binding<String>
//
//        init(_ text: Binding<String>) {
//            self.text = text
//        }
//
//        func textViewDidChange(_ textView: UITextView) {
//            self.text.wrappedValue = textView.text
//        }
//    }
//}

struct VideoDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        VideoDescriptionView(item: GTLRYouTube_Video(), channelImageData: Data(count: 10), date: GTLRDateTime(), likes: "", viewCounts: 10) {
        }
    }
}
