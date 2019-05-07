package main
import (
    id3 "github.com/mikkyang/id3-go"
    "log"
    "fmt"
    "flag"
)

func main(){
    flag.Parse()
    args := flag.Args()
    if (len(args) < 2){
        log.Fatal(fmt.Errorf("too few arguments"))
    }
    mode := args[0]
    if (mode != "set" && mode != "get"){
        log.Fatal(fmt.Errorf("invalid arguments"))
    }
    name := args[1]
    mp3File, err := id3.Open(name)
    defer mp3File.Close()
    if err != nil {
        log.Fatal(err)
    }

    switch mode{
    case "get":
        fmt.Println(mp3File.Title())
        fmt.Println(mp3File.Artist())
        fmt.Printf(mp3File.Album())
    case "set":
        for index := 2; index < len(args); index += 1 {
            if (len(args) < index + 2){
                log.Fatal(fmt.Errorf("invalid number of arguments: %d", len(args)))
            }
            target := args[index]
            index += 1
            value := args[index]
            switch target{
            case "title":
                mp3File.SetTitle(value)
            case "artist":
                mp3File.SetArtist(value)
            case "album":
                mp3File.SetAlbum(value)
            default:
                log.Fatal(fmt.Errorf("invalid arguments"))
            }
        }
    }
}

