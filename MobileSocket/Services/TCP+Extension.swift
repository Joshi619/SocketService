//
//  TCP+Extension.swift
//  MobileSocket
//
//  Created by Aditya on 20/01/25.

import Foundation
import Network

// MARK: - StreamDelegate
extension TCPNetworkService: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .errorOccurred:
            guard let error = aStream.streamError?.localizedDescription else { return }
            if(aStream === outputStream)
            {
                print("Output: \(aStream.streamError?.localizedDescription ?? "")")
            }
            print("Input: \(aStream.streamError?.localizedDescription ?? "")")
            close()
            delegate?.TcpConnectionState(state: "Disconnected")
        case .endEncountered:
            if(aStream === outputStream)
            {
                print("The Output stream has been reached.")
            }
            print("The Input stream has been reached.")
            close()
            delegate?.TcpConnectionState(state: "Disconnected")
        case .hasBytesAvailable:
//            Utils.printLog("HasBytesAvaible", logtype: .Debug)
            var buffer = [UInt8](repeating: 0, count: 81600)
            if (aStream == inputStream) {
                while ((inputStream?.hasBytesAvailable) != nil){
                    let len = inputStream?.read(&buffer, maxLength: buffer.count) ?? 0
                    if(len > 0){
                        let output = String(bytes: buffer, encoding: .ascii)
                        if (output != ""){
                            #if DEBUG
                                print("Received Response from Server:\(output ?? "")")
                            #endif
                            self.delegate?.receivedData(response: output ?? "")
                            break
                        }
                    }
                    break
                }
            }
        case .openCompleted:
            counter += 1
            if(aStream == outputStream)
            {
                print("Output = openCompleted")
            }
            openCompleted(stream: aStream)
            print("Input = openCompleted")
        case .hasSpaceAvailable:
            counter += 1
//            Utils.printLog("HasSpaceAvailable", logtype: .Information)
        default:
            print("Connection Unknown Error with \(CommonDefine.hostAddress) \(CommonDefine.ipPort)")
            delegate?.handleErrors(error: "Connection error")
            print("Unkown Error")
        }
    }
    
    func close(){
        print("Close stream called")
        if let inputStr = self.inputStream {
            inputStr.delegate = nil
            inputStr.close()
            inputStr.remove(from: .current, forMode: RunLoop.Mode.common)
        }
        if let outputStr = self.outputStream {
            outputStr.delegate = nil
            outputStr.close()
            outputStr.remove(from: .current, forMode: RunLoop.Mode.common)
        }
    }
    
    func openCompleted(stream: Stream){
        
        if let input = self.inputStream, let output = self.outputStream,
            (input.streamStatus == .open && output.streamStatus == .open){
            print("Input and Output Stream Open")
        }
    }
}
