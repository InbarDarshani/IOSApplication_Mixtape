import Foundation
import Alamofire
import SwiftyJSON

class SpotifyApi {
    
    static func getAccessToken(onComplete:@escaping (_ accessToken:String?)->Void){
        let client_id = "83074d8a068a4d8791e1636a8cbfa874"
        let client_secret = "3147ad09c9bc4c1489d442c04b2d3f9a"
        let url = "https://accounts.spotify.com/api/token"
        let authorization = "Basic " + ((client_id + ":" + client_secret).data(using: .utf8)?.base64EncodedString())!
        let headers:HTTPHeaders = [ "Authorization": authorization ]
        let body = ["grant_type":"client_credentials"]
        
        AF.request(url, method: .post, parameters:body, headers:headers).responseString() { response in
            switch response.result{
                case .success(_):
                    do {
                        let json = try JSON(data: response.data!)
                        let token = (json["access_token"]).string
                        onComplete(token)
                    } catch {
                        NSLog("TAG SpotifyApi - error pharsing to json")
                        onComplete(nil)
                    }
                case .failure(let error):
                    NSLog("TAG SpotifyApi - error getting token \(error)")
                    onComplete(nil)
            }
        }
    }
    
    static func getTrackImage(songTitle:String, songArtist:String, onComplete:@escaping (_ imageUrl:String? )->Void){
        //Spotify WebAPI Docs - https://developer.spotify.com/documentation/web-api/reference/#/operations/search
        //Spotify WebAPI Console - https://developer.spotify.com/console/get-search-item/
        //https://api.spotify.com/v1/search?q=track%3APsycho%2C%20Pt.%202%20artist%3Aruss&type=track
        var result:String? = nil
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        getAccessToken(){ accessToken in
            guard accessToken != nil else{ dispatchGroup.leave(); return; }
            let headers:HTTPHeaders = [ "Content-Type": "application/json", "Authorization": "Bearer " + accessToken! ]
            var url = URLComponents(string: "https://api.spotify.com/v1/search")
            url?.queryItems = [
                URLQueryItem(name: "q", value: "track:\(songTitle) artist:\(songArtist)"),
                URLQueryItem(name: "type", value: "track"),
                URLQueryItem(name: "limit", value: "1")
            ]
            NSLog("TAG SpotifyApi - request url \(url)")
            
            //Get image url from song album first image
            AF.request(url!, headers:headers).responseString() { response in
                switch response.result {
                    case .success(_):
                        do {
                            
                            //Parse data respons to JSON like object and export image url
                            let json = try JSON(data: response.data!)
                            result = (json["tracks","items"][0]["album","images"][0]["url"]).string ?? nil
                            NSLog("TAG SpotifyApi - response image url \(result)")
                            
                        } catch { NSLog("TAG SpotifyApi - error pharsing to json") }
                    case .failure(let error): NSLog("TAG SpotifyApi - error fetching track \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main){ onComplete(result) }
    }
    
    
    
}
