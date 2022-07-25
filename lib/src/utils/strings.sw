library strings;
use std::{vec::*};

struct String {
    raw: Vec<u8>,
}

impl String {
    pub fn new() -> Self {
        String {
            raw: Vec::new()
        }
    }
    pub fn with_capacity(capcity: u64) -> Self {
        String {
            raw: Vec::with_capacity(capacity)
        }
    }
}