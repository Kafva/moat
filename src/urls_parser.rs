use std::{
    fs::File,
    io::{prelude::*, BufReader}
};


/// Extract a list of all muted feeds from the provided ~/.newsboat/urls file
/// Each line is expected to follow this format:
///   <rss url>  <display url>    <tag> <name>
/// Names that start with '!' are muted and the corresponding <rss url> will be
/// part of the output vector.
/// Except for the <name>, no fields are allowed to contain blankspace
pub fn get_muted(urls_path: &str) -> Result<Vec<String>, std::io::Error> {
    let muted = Vec::new();
    let file = File::open(urls_path)?;

    for line in BufReader::new(file).lines() {
         let line   = line.unwrap(); 
         let rssurl = line.split_whitespace().next().unwrap_or("");
         println!("{:#?}", rssurl);
        
    }

    return Ok(muted);
}

//============================================================================//
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_muted() {
        let muted = get_muted("/Users/jonas/.newsboat/urls");
        assert!( muted.into_iter().count() > 0 );
    }

}

