use crate::moat_error;
use crate::config::{TLS_KEY,TLS_CERT};
use crate::MOAT_KEY_ENV;
use rustls::{
    Certificate,
    PrivateKey,
    ServerConfig
};
use std::{
  io::prelude::*,
  io::BufReader,
  fs::File,
  path::Path,
};

pub fn expand_tilde(value: &str) -> String {
    value.replace("~", std::env::var("HOME").unwrap().as_str())
}

pub fn get_env_key() -> String {
    let key = std::env::var(MOAT_KEY_ENV)
              .unwrap_or_else(|_| {
                  moat_error!("Missing '{}'", MOAT_KEY_ENV);
                  panic!("Error retrieving key")
              });
    if key == "" {
        moat_error!("Missing '{}'", MOAT_KEY_ENV);
        panic!("Key is unset")
    }
    key
}

pub fn get_tls_config(tls_dir: String) -> rustls::ServerConfig {
    let ec_header = "-----BEGIN EC PRIVATE KEY-----";
    let pkcs8_header = "-----BEGIN PRIVATE KEY-----";
    let mut pem_header = String::default();

    let config = ServerConfig::builder()
        .with_safe_defaults()
        .with_no_client_auth();

    let key_path =  &format!("{}/{}", tls_dir.clone(), TLS_KEY);
    let key_file = File::open(&key_path).unwrap_or_else(|_| {
        moat_error!("Missing '{}'", key_path);
        panic!("No TLS key");
    });

    let cert_path =  &format!("{}/{}", tls_dir.clone(), TLS_CERT);
    let cert_file = File::open(&cert_path).unwrap_or_else(|_| {
        moat_error!("Missing '{}'", cert_path);
        panic!("No TLS certficate");
    });

    let key_buf = &mut BufReader::new(key_file);
    let cert_buf = &mut BufReader::new(cert_file);

    key_buf.read_line(&mut pem_header).unwrap();
    key_buf.seek(std::io::SeekFrom::Start(0)).unwrap();

    // Look for a RSA or EC key in `key.pem`.
    let mut keys = if pem_header.starts_with(ec_header) {
        rustls_pemfile::ec_private_keys(key_buf).unwrap()

    } else if pem_header.starts_with(pkcs8_header) {
        rustls_pemfile::pkcs8_private_keys(key_buf).unwrap()

    } else {
        panic!("Unknown PEM key format")
    };

    if keys.is_empty() {
        moat_error!("No RSA or EC private key in '{}'", TLS_KEY);
        panic!("Failed to read private key")
    }

    let cert_chain = rustls_pemfile::certs(cert_buf)
        .unwrap()
        .into_iter()
        .map(Certificate)
        .collect();

    // Pop out the first key from the PEM file
    config.with_single_cert(cert_chain, PrivateKey(keys.remove(0))).unwrap()
}

pub fn path_exists(path_str: &str) -> Result<String,String> {
    let expanded_path = expand_tilde(path_str);
    let filepath = Path::new(expanded_path.as_str());

    if !filepath.is_file() {
        Err("No such file".to_string())
    } else {
        Ok(String::from(path_str))
    }
}

//============================================================================//

#[cfg(test)]
pub fn run_setup_script() {
    std::process::Command::new("./scripts/test_setup.sh").output()
        .expect("Test setup failed");
}



