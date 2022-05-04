//
//  ContentView.swift
//  VisionAndNFC
//
//  Created by 隠塚永治 on 2021/12/05.
//

import SwiftUI

struct ContentView: View {
    // ViewModelをStateObjectに指定し、Published 属性の変数を購読する
    @StateObject var viewModel = ViewModel()
    @State private var isDetected = false
    @State private var detectedCode = ""
    //@State private var NFCData = ""
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // previewLaerView
                PreviewLayerView (
                    // viewModel で @Published の変数
                    previewLayer: viewModel.previewLayer,
                    detectedRect: viewModel.detectedRects,
                    detectSize: viewModel.cropSize,
                    pixelSize: viewModel.pixelSize
                )
                // 文字認識の場合は画面をタップで動作する
                .onTapGesture{
                    if viewModel.getMode() == .Text {
                        viewModel.setOnTap()
                    }
                }
                VStack{
                    // NFC読み込みボタン
                    Button(action: {
                        viewModel.nfcRead()
                    })
                    {
                        Text("NFC読み込み")
                            .fontWeight(.semibold)
                    }
                    .frame(width: 240, height: 48)
                    .background(Color.gray)
                    .foregroundColor(Color(.white))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(.blue), lineWidth: 5.0)
                    )
                    .padding(25)
                    
                    
                    if viewModel.NFCData != "" {
                        Text(viewModel.NFCData)
                            .frame(width: 320, height: 48)
                            .background(Color.white.opacity(0.5))
                            .foregroundColor(Color(.black))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.blue), lineWidth: 5.0)
                            )
                    }
                    // NFC Write Button
                    if let detectedCode = viewModel.getDetectedCode() {
                        Button(action: {
                            self.detectedCode = detectedCode
                            self.isDetected = true
                            
                        })
                        {
                            Text(detectedCode)
                                .frame(width: 320, height: 48)
                                .background(Color.yellow.opacity(0.5))
                                .foregroundColor(Color(.black))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.red), lineWidth: 5.0)
                                )
                        }
                        .padding()
                        .sheet(isPresented: self.$isDetected){
                            NFCWriteView(detectedCode: self.$detectedCode)
                        }
                    }
                    Spacer()
                    // zoom用スライダー
                    Slider(
                        value: $viewModel.zoomValue,
                        in: 1.0...4.0,
                        onEditingChanged: {bool in
                            viewModel.setZoomValue(bool: bool)
                        })
                        .padding(
                            EdgeInsets(
                                top:10,
                                leading: 20,
                                bottom: 10,
                                trailing: 20
                            )
                        )
                    HStack{
                        // クリアボタン: 初期状態に戻す
                        Button(action: {
                            viewModel.stopSession()
                            viewModel.NFCData = ""
                            viewModel.setNFCData(NFCData: viewModel.NFCData)
                            viewModel.setCancel()
                        })
                        {
                            Text("クリア")
                                .font(.title)
                                .frame(width: 150, height: 48)
                                .background(Color.white.opacity(0.5))
                                .foregroundColor(Color(.black))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.green), lineWidth: 5.0)
                                )
                        }
                        .padding()
                        // 認識切り替えボタン
                        // バーコードとテキストの認識を切り替え
                        Button(action: {
                            viewModel.stopSession()
                            viewModel.setNFCData(NFCData: viewModel.NFCData)
                            viewModel.setNextMode()
                        })
                        {
                            Text(viewModel.nextModeString)
                                .font(.title)
                                .frame(width: 150, height: 48)
                                .background(Color.white.opacity(0.5))
                                .foregroundColor(Color(.black))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.green), lineWidth: 5.0)
                                )
                        }
                        .padding()
                    }
                }
            }
            // 画面全体を使用
            .edgesIgnoringSafeArea(.all)
            // 画面が呼び出された時に起動
            .onAppear {
                viewModel.startSession()
                viewModel.setGeometrySize(size: geometry.size)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
