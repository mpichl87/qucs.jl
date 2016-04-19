module QUCS

import Base.string, Base.print, Base.show
export QucsData

using PyCall
unshift!( PyVector( pyimport( "sys" )[ "path" ] ), "" )
@pyimport qucs

typealias QucsName 	AbstractString
typealias QucsNames	Vector{ QucsName }
typealias QucsVal	Complex{ Float64 }
typealias QucsVals	Vector{ QucsVal }

type QucsIndep
	name::QucsName
	vals::QucsVals
end

string( x::QucsIndep ) = "$( x.name ): $( length( x.vals ) ) entries"
show( io::IO, x::QucsIndep ) = print( io, "QucsIndep <$x>" )

typealias QucsIndeps Dict{ QucsName, QucsVals }

function QucsIndeps( o::PyObject )
	QucsIndeps( o[ :indeps ] )
end

type QucsDep
	ind_vars::QucsNames
	val::Array{ Complex{ Float64 } }
end

QucsDep( o::PyObject ) = QucsDep( o[ :ind_vars ], o[ :val ] )

typealias QucsDeps Dict{ QucsName, QucsDep }

function QucsDeps( o::PyObject )
	deps = o[ :deps ]
	QucsDeps( [ key => QUCS.QucsDep( deps[ key ] ) for key in keys( deps ) ] )
end

type QucsData
	indeps::QucsIndeps
	deps::QucsDeps
end

function QucsData( path::AbstractString )
	o = qucs.qucs_data( path )
	QucsData( QucsIndeps( o ), QucsDeps( o ))
end

end