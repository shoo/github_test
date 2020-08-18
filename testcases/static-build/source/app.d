import std;

import bindbc.icu;

int main()
{
	auto status = U_ZERO_ERROR;
	UCharsetDetector* detector = ucsdet_open(&status);
	enforce(U_SUCCESS(status));
	scope (exit)
		ucsdet_close(detector);
	
	auto textbuf = cast(Char[])std.file.read("../.testresources/utf-8.txt");
	
	ucsdet_setText(detector, textbuf.ptr, cast(int)textbuf.length, &status);
	enforce(U_SUCCESS(status));
	
	int found;
	auto matchers = ucsdet_detectAll(detector, &found, &status);
	
	string[] results;
	foreach (i; 0..found)
	{
		immutable confidence = ucsdet_getConfidence(matchers[i], &status);
		enforce(U_SUCCESS(status));
		
		if (confidence < 10)
			break;
		
		auto encoding = ucsdet_getName(matchers[i], &status);
		enforce(U_SUCCESS(status));
		
		results ~= encoding.toStringFromAscii();
	}
	
	results.canFind("UTF-8").enforce();
	
	return 0;
}

///
string toStringFromAscii(in char* s)
{
	import core.stdc.string: strlen;
	auto len = strlen(s);
	// ASCII only == UTF-8
	return s[0..len].idup;
}
