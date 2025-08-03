//
//  DropboxAPI.swift
//  RealtimePinboard
//
//  Created by 結城 賢斗 on 2025/08/03.
//

import Foundation
import AppKit

let token = "sl.u.AF7SFpWTrzaShXOb_NeNu-P4fdqQki1GJDfz0u0QINaAdj-B2iBV7GbpLO6HQFmXt4UmSArJRRVoq0rfw9q5IEjiYqot_aaNWwIgl_Tk_D0IMRyg0lrPakWJfpmbbmeYBAuDpkdnc8xSP3aAZkX9b3senB1sdqULXsSwqwP35jjBPt8rh63YWuCp6rLx5dFWfyD5mp-xzsXMq2KjvMXhW0QXvm1faYmS8qCWC8hY4ZB9jQUsVoURojMWaEqhAa0-JU6UtFhRhf2l30Pl9GkSreEt-rcLUct-1d9lQIZi_W7Yd0E4l5h5QKtACt-1MeTOE7as11-mZpHv3LciQXd_5iOVIH-yMIxKIajmaagGi2v3qmwg9r3viEuhvYtIBeUzBDt4RNZMck-dpIiqkRHlLoTTZnnPz9lpW6p3Q0iLsdTtI5Uulu7-LdJqlQeEgdFmCoBmxdItWT3Wdl0KaxMcAVel8ndwPr1fey7uonqPpSo0MqMCJwmfRGqRJb_EbZDnWJ1SBOGL4yOuyhG_5sXrUdL3s8NE-eU1j5aSgNqzrxi17Ib3laRC4aHEo3aX-vNm4TGhGdzsAZvUIxw1Wu375JB5Wj6PDN1B9SBzOt2iyieH1qovBwHEIn8CDfiaw0EVKAcIdfODdr6myJfJ_Lyp3LxIKVroWLoFplcWTxrChsr2w2v381LRvbX6bz9BGHAOyfSXbJXaNzDHKzoIZsF83OpP5Eqnr46NCsYkjimns4EQFzmt4R7kGQUCJ9Bx1vwky6Aor1AeSXLjGGFIaYiKv0jzShRIolnCMq0smcQ_v7R_tEKIczlq-Ls9Rx1cQXJpIZyGbvYui4FtXYcP3ckYi_wz2ENnWT97_HlUqZyklVw28-Tf14QIItrGhyDrDVcJV_yO_3AK9u2CC5r-jQv0tP6Kru0-7Ce1gRB7ZKJZaTVoabb1WGmpoMIKjybfO5xGMs44hOBfSnftF0ZyFB9vghkRRFe23Ay-4OQyYDV1tjvM2wsadS05J5adwgQkDjd9MsnYRnISxaq0ureZzdWw6iPSgZf5LET2CiVfvVU_RxTs42RkYCS1Z5JvjmJmIt_8pow9_PTV-la4cEZvvnFf4wbuCOhEV19DJSe9BGdqZeHkaVJWHlPlWXdWy3KhuierY62z1V-elk9XI25K4QSdCuTjlxyOb2qO-dIx9nvbYUB4-P7blzGvbfTaoNX6ChaniUPqQgmY3pqp8488KKVd40E25ELl5jcX83koh7S31vJ--XKKTQJuv2BCDupkga_C-fXIV5LcvHjhM1V5thjhRKS0Pd1VEXVX2r7waAsrNYM0sNO1vJnGm4yv_fQyLOdm_xA4ZToi3PMwW47lWwCITm1yaX5N4TB0BryjV18HAVnCj3CGwxQ5FnJMXXyIPkBsre_oHcra-yFY-hjQuKDJ8OW4sERz3UfwbIr7APWrSJHZ-Q"


struct DropboxListResponse: Codable {
    let entries: [DropboxEntry]
}

struct DropboxEntry: Codable {
    let name: String
    let pathLower: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case pathLower = "path_lower"
    }
}

class DropboxAPI{
   
    
    func fetchImageList() async throws -> [String]{
        var imagePaths: [String] = []
        
        guard let url = URL(string: "https://api.dropboxapi.com/2/files/list_folder")else {
            fatalError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = ["path": ""] // App Folderなら "" or "/Apps/YourApp"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoded = try JSONDecoder().decode(DropboxListResponse.self, from: data)
            imagePaths = decoded.entries
                .filter { $0.name.lowercased().hasSuffix(".jpg") || $0.name.lowercased().hasSuffix(".png") }
                .map { $0.pathLower }
        } catch {
            print("エラー: \(error)")
            throw URLError(.cannotDecodeContentData)
        }
        return imagePaths
    }
    
    func downloadImage(path: String, accessToken: String) async throws -> NSImage {
        guard let url = URL(string: "https://content.dropboxapi.com/2/files/download") else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("{\"path\": \"\(path)\"}", forHTTPHeaderField: "Dropbox-API-Arg")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let image = NSImage(data: data) else {
            print("imageDataなし")
            throw URLError(.cannotDecodeContentData)
        }
        return image
    }
    
    func downloadImageWithRetry(path: String, accessToken: String, retries: Int = 3) async throws -> NSImage {
        URLCache.shared.removeAllCachedResponses()
        for attempt in 1...retries {
            do {
                return try await downloadImage(path: path, accessToken: accessToken)
            } catch let error as URLError where error.code == .networkConnectionLost {
                print("Connection lost, retrying... (\(attempt))")
                try? await Task.sleep(nanoseconds: UInt64(300_000_000 * attempt)) // 0.3s, 0.6s, ...
            } catch {
                throw error // 他のエラーなら即終了
            }
        }
        throw URLError(.networkConnectionLost)
    }
    
}
