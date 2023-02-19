use std::{
    fs::File,
    io::{prelude::*, BufReader},
};


pub struct Muted {
    pub entries: Vec<String>,
}

//============================================================================//

impl Muted {
    /// Extract a list of all muted feeds from the provided ~/.newsboat/urls file
    /// Each line is expected to follow this format:
    ///   <rss url>  <display url>    <tag> <name>
    /// Names that start with '!' are muted and the corresponding <rss url> will be
    /// part of the output vector.
    /// Except for the <name>, no fields are allowed to contain blankspace.
    pub fn from_urls_file(urls: &str) -> Result<Self,std::io::Error> {
        let mut entries: Vec<String> = Vec::new();
        let file = File::open(urls)?;

        for line in BufReader::new(file).lines().map(|l| l.unwrap()) {
            if line.trim().starts_with("http") {
                let fields: Vec<&str> = line.split_whitespace().collect();

                let last_field = fields.get(3).expect("error parsing urls file");
                if last_field.trim_matches('"').starts_with("!") {
                    let rssurl = fields.get(0).expect("error parsing urls file");
                    let entry = String::from(*rssurl);
                    entries.push(entry);
                }
            }
        }

        return Ok(Self { entries });
    }
}

//============================================================================//
#[cfg(test)]
mod tests {
    use crate::util::expand_tilde;
    use crate::muted::Muted;
    use std::fs::File;

    fn setup() {
        std::process::Command::new("./scripts/test_setup.sh").output()
            .expect("Test setup failed");
    }


    /// To see stdout of tests:
    ///  cargo test -- --nocapture
    #[test]
    fn test_get_muted() {
        setup();
        let muted_path = expand_tilde("/tmp/moat/urls");
        let muted = Muted::from_urls_file(&muted_path).unwrap();
        assert!(muted.entries.into_iter().count() > 0);

        let _ = File::create("/tmp/empty");
        let muted = Muted::from_urls_file("/tmp/empty").unwrap();
        assert!(muted.entries.into_iter().count() == 0);
    }
}

