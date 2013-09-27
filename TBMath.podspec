Pod::Spec.new do |s|
	s.name		= "TBMath"
	s.version	= "0.0.1"
	s.summary 	= "Objective-C math library written on top of accelerate."
	s.homepage	= "https://github.com/thoughtbot/TBMath.git"
	s.license	= 'MIT'
	s.author 	= {"Theodore Calmes" => "theo@thoughtbot.com"}
	s.source    = { 
    	:git => "https://github.com/thoughtbot/TBMath.git",
    	:tag => "0.0.4"
  	}
  	s.source_files = 'TBMath/**/*.{m,h}'
	s.requires_arc = true
	s.frameworks    = 'Accelerate'
	s.documentation = { 
		:appledoc => [
			'--project-name',      s.name + ' ' + s.version.to_s(),
			'--project-company',   'thoughtbot',
			'--docset-copyright',  'thoughtbot',
	    	'--ignore',            'TBMathTests',
	    	'--no-keep-undocumented-objects',
	    	'--no-keep-undocumented-members',
	    	'--no-repeat-first-par',
	    	'--no-warn-invalid-crossref'
	    ]
	}
end
