use super::reader::IDRISDBReader;

pub trait IDRISDBCursor {
    type Reader<'a>: IDRISDBReader
    where
        Self: 'a;

    fn next(&mut self, id: i64) -> Option<Self::Reader<'_>>;
}

pub trait IDRISDBQueryCursor {
    type Reader<'a>: IDRISDBReader
    where
        Self: 'a;

    fn next(&mut self) -> Option<Self::Reader<'_>>;
}
