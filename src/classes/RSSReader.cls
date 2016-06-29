global with sharing class RSSReader {
     
    public class channel {
        public String title {get;set;}
        public String link {get;set;}
        public String description {get;set;}
        public String author {get;set;}
        public String category {get;set;}
        public String copyright {get;set;}
        public String docs {get;set;}
        public RSSReader.image image {get;set;}
        public list<RSSReader.item> items {get;set;}
        public channel() {
            items = new list<RSSReader.item>();
        }
    }
     
    public class image {
        public String url {get;set;}
        public String title {get;set;}
        public String link {get;set;}
    }
     
    public class item {
        public String title {get;set;}
        public String guid {get;set;}
        public String link {get;set;}
        public String description {get;set;}
        public String pubDate {get;set;}
        public String source {get;set;}
      
        public DateTime getPublishedDateTime() {
            DateTime result = (pubDate != null) ? DateTime.valueOf(pubDate.replace('T', ' ').replace('Z','')) : null;
            return result;
        }
    }
    
     
    
 
}