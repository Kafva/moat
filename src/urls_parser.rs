use std::{
    fs::File,
    io::{prelude::*, BufReader},
};

/// Extract a list of all muted feeds from the provided ~/.newsboat/urls file
/// Each line is expected to follow this format:
///   <rss url>  <display url>    <tag> <name>
/// Names that start with '!' are muted and the corresponding <rss url> will be
/// part of the output vector.
/// Except for the <name>, no fields are allowed to contain blankspace
pub fn get_muted(urls_path: String) -> Result<Vec<String>, std::io::Error> {
    let mut muted: Vec<String> = Vec::new();
    let file = File::open(urls_path)?;

    for line in BufReader::new(file).lines() {
        let line = line.unwrap();
        if line.trim().starts_with("http") {
            let fields: Vec<&str> = line.split_whitespace().collect();

            let last_field = fields.get(3).expect("error parsing urls file");
            if last_field.trim_matches('"').starts_with("!") {
                let rssurl = fields.get(0).expect("error parsing urls file");
                let muted_entry = String::from(*rssurl);
                muted.push(muted_entry);
            }
        }
    }

    return Ok(muted);
}

//============================================================================//
#[cfg(test)]
mod tests {
    use crate::expand_tilde;
    use crate::get_muted;
    use std::fs::File;

    #[test]
    // To see stdout of tests:
    //  cargo test -- --nocapture
    fn test_get_muted() {
        let muted =
            get_muted(expand_tilde(String::from("~/.newsboat/urls"))).unwrap();
        assert!(muted.into_iter().count() > 0);

        let _ = File::create("/tmp/empty");
        let muted = get_muted("/tmp/empty".to_string()).unwrap();
        assert!(muted.into_iter().count() == 0);
    }
}
