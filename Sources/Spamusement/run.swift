import Foundation
import PathKit
import Saga
import SagaParsleyMarkdownReader
import SagaSwimRenderer
import HTML

struct ComicMetadata: Metadata {
  let id: Int
  let title: String
  var date: Date
}

func baseLayout(title pageTitle: String, @NodeBuilder children: () -> NodeConvertible) -> Node {
  return [
    .documentType("html"),
    html(lang: "en-US") {
      head {
        meta(charset: "utf-8")
        link(href: "/style.css", rel: "stylesheet")
        title { pageTitle }
        script(defer: true, src: "/script.js", customAttributes: ["data-website-id": "4268260a-c4c9-4dde-99a4-3e73abd21aae"])
      }

      body {
        div(class: "container") {
          children()
        }
      }
    }
  ]
}

func renderIndex(context: ItemsRenderingContext<ComicMetadata>) -> Node {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "MMMM dd, yyyy"
  dateFormatter.timeZone = .current
  
  return baseLayout(title: "Spamusement! Poorly-drawn cartoons inspired by actual spam subject lines!") {
    div(class: "center header") {
      img(alt: "Spamusement!", src: "/images/banner.webp")
      p {
        strong {
          "Poorly-drawn cartoons inspired by actual spam subject lines!"
        }
      }
      p(class: "disclaimer") {
        "This site is an archive of the amazing spamusement.com, which sadly went offline in 2020. It is in no way endorsed by or affiliated with the author"
        a(href: "https://stevenf.com") { "Steven Frank" }
        %". Copyright belongs to Steven Frank. This archive was created by a fan so these comics don't disappear from the internet."
      }
    }
    
    context.items.map { item in
      p {
        a(href: item.url) { item.metadata.title }
        br()
        span { dateFormatter.string(from: item.metadata.date) }
      }
    }
  }
}

func renderComic(context: ItemRenderingContext<ComicMetadata>) -> Node {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "MMMM dd, yyyy"
  dateFormatter.timeZone = .current
  
  return baseLayout(title: context.item.metadata.title) {
    div(class: "comic") {
      h1(class: "center") { context.item.metadata.title }
      img(alt: context.item.metadata.title, src: "/images/\(context.item.metadata.id).webp")
    }
    
    div(class: "pagination") {
      div {
        if let previous = context.previous {
          a(href: previous.url) { "← " + previous.metadata.title }
        }
      }
      
      div(class: "right") {
        if let next = context.next {
          a(href: next.url) { next.metadata.title + " →" }
        }
      }
    }
    
    div(class: "center") {
      a(href: "/") { "View all comics" }
    }
  }
}

@main
struct Run {
  static func main() async throws {
    try await Saga(input: "content", output: "deploy")
      .register(
        metadata: ComicMetadata.self,
        readers: [.parsleyMarkdownReader],
        itemWriteMode: .keepAsFile,
        sorting: { $0.metadata.id > $1.metadata.id },
        writers: [
          .listWriter(swim(renderIndex)),
          .itemWriter(swim(renderComic)),
        ]
      )
      .run()
      .staticFiles()
  }
}
