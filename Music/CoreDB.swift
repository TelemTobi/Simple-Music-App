//
//  CoreDB.swift
//  Music
//
//  Created by Telem Tobi on 01/01/2020.
//
import UIKit
import CoreData

class CoreDB {
    
    private init(){}
    public static let shared = CoreDB()

    public var container: NSPersistentContainer!
    
    public func setup(dataModelName: String) {
        container = NSPersistentContainer(name: dataModelName)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
    
    func fetchSavedSongs() {
        let fetchRequest: NSFetchRequest<CoreSong> = CoreSong.fetchRequest()
        
        guard let array = try? container.viewContext.fetch(fetchRequest) else { return }
        for song in array {
            savedSongs[song.title!] = song
            print(song.title ?? "nil")
        }
    }
    
    func saveSong(_ song: Song? = nil, artistName: String, core: CoreSong? = nil) {
        container.performBackgroundTask { context in
            let coreSong = CoreSong(context: context)
            
            coreSong.title = song?.title ?? core?.title
            coreSong.cover_image = song?.album.cover_medium ?? core?.cover_image
            coreSong.preview =  song?.preview ?? core?.preview
            coreSong.artist_name = artistName
            
            savedSongs[coreSong.title!] = coreSong
            try! context.save()
            print("saved successfuly")
        }
    }
    
    func removeSong(_ coreSong: CoreSong) {
        
        guard let context = coreSong.managedObjectContext else { return }
        context.delete(coreSong)
        savedSongs.removeValue(forKey: coreSong.title!)
        
        try! context.save()
        print("removed successfuly")
    }
}

