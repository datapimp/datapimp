### Support For Additional Data Sources

- JSON API 
  
  ```
  datapimp sync data --type=json https://api.github.com/orgs/architects/repos
  ```

- NOKOGIRI

  The nokogiri datatype should support using CSS selectors to extract
  an array of key value pairs from a URL.  For example, pulling all of the data
  from the product hunt website: 

  http://www.producthunt.com
  records=ul.posts-group li.post 
  record=TODO (figure out syntax mapping data to css selectors)

  ```
  datapimp sync data --type=nokogiri http://www.producthunt.com --selectors=file
  ```

- Implement converting an XLSX document on Dropbox to JSON  
