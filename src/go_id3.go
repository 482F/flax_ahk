package main
import (
    id3 "github.com/mikkyang/id3-go"
    "golang.org/x/text/encoding/japanese"
    "golang.org/x/text/transform"
    "golang.org/x/text/encoding"
    "strings"
    "io/ioutil"
    "log"
    "fmt"
    "flag"
)

func utf8_to_sjis(str string) (string, error) {
        str_reader := strings.NewReader(str)
        sjis_encoder := japanese.ShiftJIS.NewEncoder()
        sjis_encoder = encoding.ReplaceUnsupported(sjis_encoder)
        trs_reader := transform.NewReader(str_reader, sjis_encoder)
        ret, err := ioutil.ReadAll(trs_reader)
        if err != nil {
                return "", err
        }
        return string(ret), err
}

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
        title := mp3File.Title()
        title, err = utf8_to_sjis(title)
        if err != nil{
            log.Fatal(err)
        }
        artist := mp3File.Artist()
        artist, err = utf8_to_sjis(artist)
        if err != nil{
            log.Fatal(err)
        }
        album := mp3File.Album()
        album, err = utf8_to_sjis(album)
        if err != nil{
            log.Fatal(err)
        }
        fmt.Println(title)
        fmt.Println(artist)
        fmt.Printf(album)
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

