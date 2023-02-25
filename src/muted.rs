use super::moat_error;
use std::{
    fs::File,
    io::{prelude::*, BufReader},
};

#[derive(Debug)]
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
        let mut entries: Vec<String> = vec![];
        let file = File::open(urls)?;

        for (i,line) in BufReader::new(file).lines().map(|l| l.unwrap()).enumerate() {
            if line.trim().starts_with("http") {
                let fields: Vec<&str> = line.split_whitespace().collect();

                if let Some(last_field) = fields.get(3) {
                    if last_field.trim_matches('"').starts_with("!") {
                        if let Some(rssurl) = fields.get(0) {
                            let entry = String::from(*rssurl);
                            entries.push(entry);
                        } else {
                            moat_error!("Error parsing {}:{}", urls, i);
                        }
                    }
                } else {
                    moat_error!("Error parsing {}:{}", urls, i);
                }
            }
        }
        return Ok(Self { entries });
    }


    /// Create a comma separated string of all entries, with each being
    /// enclosed in double quotes.
    pub fn as_quoted_csv(&self) -> String {
        let enclosed: Vec<String> = self.entries.iter()
            .map(|e| format!("'{}'", e).to_string())
            .collect();

        enclosed.join(",")
    }
}

//============================================================================//

#[cfg(test)]
mod tests {
    use crate::util::{expand_tilde,run_setup_script};
    use crate::muted::Muted;
    use std::fs::File;

    fn setup() {
        run_setup_script()
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

