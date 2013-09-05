class SetupHstore < ActiveRecord::Migration
  def self.up
    sql = <<-HSTORE_SQL
/* $PostgreSQL: pgsql/contrib/hstore/hstore.sql.in,v 1.11 2009/06/11 18:30:03 tgl Exp $ */

-- Adjust this setting to control where the objects get created.
SET search_path = public;

CREATE TYPE hstore;

CREATE OR REPLACE FUNCTION hstore_in(cstring)
RETURNS hstore
AS '$libdir/hstore'
LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION hstore_out(hstore)
RETURNS cstring
AS '$libdir/hstore'
LANGUAGE C STRICT;

CREATE TYPE hstore (
        INTERNALLENGTH = -1,
        INPUT = hstore_in,
        OUTPUT = hstore_out,
        STORAGE = extended
);

CREATE OR REPLACE FUNCTION fetchval(hstore,text)
RETURNS text
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR -> (
	LEFTARG = hstore,
	RIGHTARG = text,
	PROCEDURE = fetchval
);

CREATE OR REPLACE FUNCTION isexists(hstore,text)
RETURNS bool
AS '$libdir/hstore','exists'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION exist(hstore,text)
RETURNS bool
AS '$libdir/hstore','exists'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR ? (
	LEFTARG = hstore,
	RIGHTARG = text,
	PROCEDURE = exist,
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OR REPLACE FUNCTION isdefined(hstore,text)
RETURNS bool
AS '$libdir/hstore','defined'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION defined(hstore,text)
RETURNS bool
AS '$libdir/hstore','defined'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION delete(hstore,text)
RETURNS hstore
AS '$libdir/hstore','delete'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION hs_concat(hstore,hstore)
RETURNS hstore
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR || (
	LEFTARG = hstore,
	RIGHTARG = hstore,
	PROCEDURE = hs_concat
);

CREATE OR REPLACE FUNCTION hs_contains(hstore,hstore)
RETURNS bool
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION hs_contained(hstore,hstore)
RETURNS bool
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR @> (
	LEFTARG = hstore,
	RIGHTARG = hstore,
	PROCEDURE = hs_contains,
	COMMUTATOR = '<@',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR <@ (
	LEFTARG = hstore,
	RIGHTARG = hstore,
	PROCEDURE = hs_contained,
	COMMUTATOR = '@>',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

-- obsolete:
CREATE OPERATOR @ (
	LEFTARG = hstore,
	RIGHTARG = hstore,
	PROCEDURE = hs_contains,
	COMMUTATOR = '~',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ~ (
	LEFTARG = hstore,
	RIGHTARG = hstore,
	PROCEDURE = hs_contained,
	COMMUTATOR = '@',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OR REPLACE FUNCTION tconvert(text,text)
RETURNS hstore
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE; -- not STRICT

CREATE OPERATOR => (
	LEFTARG = text,
	RIGHTARG = text,
	PROCEDURE = tconvert
);

CREATE OR REPLACE FUNCTION akeys(hstore)
RETURNS _text
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION avals(hstore)
RETURNS _text
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION skeys(hstore)
RETURNS setof text
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION svals(hstore)
RETURNS setof text
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION each(IN hs hstore,
    OUT key text,
    OUT value text)
RETURNS SETOF record
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;



-- define the GiST support methods

CREATE TYPE ghstore;

CREATE OR REPLACE FUNCTION ghstore_in(cstring)
RETURNS ghstore
AS '$libdir/hstore'
LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION ghstore_out(ghstore)
RETURNS cstring
AS '$libdir/hstore'
LANGUAGE C STRICT;

CREATE TYPE ghstore (
        INTERNALLENGTH = -1,
        INPUT = ghstore_in,
        OUTPUT = ghstore_out
);

CREATE OR REPLACE FUNCTION ghstore_compress(internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION ghstore_decompress(internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION ghstore_penalty(internal,internal,internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION ghstore_picksplit(internal, internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION ghstore_union(internal, internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION ghstore_same(internal, internal, internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION ghstore_consistent(internal,internal,int,oid,internal)
RETURNS bool
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE STRICT;

-- register the opclass for indexing (not as default)
CREATE OPERATOR CLASS gist_hstore_ops
DEFAULT FOR TYPE hstore USING gist
AS
       	OPERATOR        7       @> ,
       	OPERATOR        9       ?(hstore,text) ,
        --OPERATOR        8       <@ ,
        OPERATOR        13      @ ,
        --OPERATOR        14      ~ ,
        FUNCTION        1       ghstore_consistent (internal, internal, int, oid, internal),
        FUNCTION        2       ghstore_union (internal, internal),
        FUNCTION        3       ghstore_compress (internal),
        FUNCTION        4       ghstore_decompress (internal),
        FUNCTION        5       ghstore_penalty (internal, internal, internal),
        FUNCTION        6       ghstore_picksplit (internal, internal),
        FUNCTION        7       ghstore_same (internal, internal, internal),
        STORAGE         ghstore;

-- define the GIN support methods

CREATE OR REPLACE FUNCTION gin_extract_hstore(internal, internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION gin_extract_hstore_query(internal, internal, int2, internal, internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION gin_consistent_hstore(internal, int2, internal, int4, internal, internal)
RETURNS bool
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS gin_hstore_ops
DEFAULT FOR TYPE hstore USING gin
AS
	OPERATOR        7       @> ,
	OPERATOR        9       ?(hstore,text),
	FUNCTION        1       bttextcmp(text,text),
	FUNCTION        2       gin_extract_hstore(internal, internal),
	FUNCTION        3       gin_extract_hstore_query(internal, internal, int2, internal, internal),
	FUNCTION        4       gin_consistent_hstore(internal, int2, internal, int4, internal, internal),
STORAGE         text;
HSTORE_SQL
    execute sql
  end

  def self.down
    # Kinda... hard.
  end
end
