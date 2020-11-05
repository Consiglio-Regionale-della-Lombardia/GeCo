function executePerc(valore1, valore2, op) {
	if (((valore1 != "0") && (valore1 != "0,00")) && ((valore2 != "0") && (valore2 != "0,00"))) {
		var valore;
		
		var inizio = valore1.toString().indexOf(',');
		var fine = valore1.toString().substring(inizio);
	
		if (inizio > -1) {
			valore1 = valore1.substring(0, inizio);
			valore1 = replaceAll(valore1, ".", "");
			valore1 = valore1 + fine;
			valore1 = replaceAll(valore1, ",", ".");
		}
		
		inizio = valore2.indexOf(',');
		var fine = valore2.substring(inizio);
	
		if (inizio > -1) {
			valore2 = valore2.substring(0, inizio);
			valore2 = replaceAll(valore2, ".", "");
			valore2 = valore2 + fine;
			valore2 = replaceAll(valore2, ",", ".");
		}
	
		switch(op){
			case '+':
				valore = (parseFloat(valore1) + parseFloat(valore2)).toFixed(2);
				break;
			case '-':
				valore = (parseFloat(valore1) - parseFloat(valore2)).toFixed(2);
				break;
			case '/':
				valore = (parseFloat(valore1) / parseFloat(valore2)).toFixed(2);
				break;
			case '*':
				valore = (parseFloat(valore1) * parseFloat(valore2)).toFixed(2);
				break;
		}
	
		valore = valore.toString().replace('.', ',');
		
	 } else {
		valore = "0";
	 }
	 
	 return valore;
}

function Formatta_NumSimple(campo, dec, sep){
	if (campo.value!="") {
		val = campo.value;
		val = replaceAll(val, '.', '');
		val = val.replace(',', '.');
		var segno = "";
		if (val.indexOf("-") > -1) {
			segno = "-";
		}
		if ((isNaN(val)) || (val.length == 0) || (val.substring(0, 1) == ".")) {
			val = 0;
		} else {
			s_val = new String(val);
			RE = /[^\d|\.,]/gi
			s_val = s_val.replace(RE,"");
			//RE = /\./gi;
			s_val = s_val.replace(RE,"");
			s_val = s_val.replace("\,","\.");
			a_val = s_val.split(".");
			intero=a_val[0];
			l_val = intero.length;
			var i = 3;
			while (l_val - 3 > 0){ 
				var l_val1 = intero.length; 
				var s1 = intero.slice( l_val1 - i , l_val1 ); 
				var s2 = intero.slice(0 , l_val1 - i ); 
				intero = s2+"."+s1; 
				i = i +4; 
				l_val = l_val - 3; 
			} 
			if(a_val.length>1) {
				s1 = String(a_val[1])
				while (s1.length<dec) {
					s1 = s1+"0";
				}
			} else { 
				s1 = "00"
			}
			val = segno + intero + sep + s1.substr(0, dec);
			
		}
		campo.value = val;
	}
	//return val;
} 
function Formatta_NumSimpleValue(campo, dec, sep){
	val = replaceAll(campo, '.', '');
	val = val.replace(',', '.');
	var segno = "";
	if (val.indexOf("-") > -1) {
		segno = "-";
	}
	if ((isNaN(val)) || (val.length == 0) || (val.substring(0, 1) == ".")) {
		val = 0;
	} else {
		s_val = new String(val);
		RE = /[^\d|\.,]/gi
		s_val = s_val.replace(RE,"");
		//RE = /\./gi;
		s_val = s_val.replace(RE,"");
		s_val = s_val.replace("\,","\.");
		a_val = s_val.split(".");
		intero=a_val[0];
		l_val = intero.length;
		var i = 3;
		while (l_val - 3 > 0){ 
			var l_val1 = intero.length; 
			var s1 = intero.slice( l_val1 - i , l_val1 ); 
			var s2 = intero.slice(0 , l_val1 - i ); 
			intero = s2+"."+s1; 
			i = i +4; 
			l_val = l_val - 3; 
		} 
		if(a_val.length>1) {
			s1 = String(a_val[1])
			while (s1.length<dec) {
				s1 = s1+"0";
			}
		} else { 
			s1 = "00"
		}
		val = segno + intero + sep + s1.substr(0, dec);
		
	}
	return val;
} 
function getOp(strSplit, txtName) {
	var iInizio = txtName.indexOf("___");
	var ntxt = txtName.substring(iInizio+3);
	var op = "0";

	for(y=0;y<strSplit.length;y++) {
		if (ntxt == strSplit[y]) {
			op = strSplit[y-1];
			break;			
		}
				
	}

	return op;
}

function executeOp(valore1, valore2, op) {
	var valore;
	
	var inizio = valore1.toString().indexOf(',');
	var fine = valore1.toString().substring(inizio);

	if (inizio > -1) {
		valore1 = valore1.substring(0, inizio);
		valore1 = replaceAll(valore1, ".", "");
		valore1 = valore1 + fine;
		valore1 = replaceAll(valore1, ",", ".");
	}

	inizio = valore2.indexOf(',');
	var fine = valore2.substring(inizio);

	if (inizio > -1) {
		valore2 = valore2.substring(0, inizio);
		valore2 = replaceAll(valore2, ".", "");
		valore2 = valore2 + fine;
		valore2 = replaceAll(valore2, ",", ".");
	}

	switch(op){
		case '+':
			valore = (parseFloat(valore1) + parseFloat(valore2)).toFixed(2);
			break;
		case '-':
			valore = (parseFloat(valore1) - parseFloat(valore2)).toFixed(2);
			break;
		case '/':
			valore = (parseFloat(valore1) / parseFloat(valore2)).toFixed(2);
			break;
		case '*':
			valore = (parseFloat(valore1) * parseFloat(valore2)).toFixed(2);
			break;
	}
	
	valore = valore.toString().replace('.', ',');
	valore = Formatta_NumSimple(valore, 2, ",");

	return valore;
}

function executeOpSimple(valore1, valore2, op) {
	var valore = "";
	
	var inizio = valore1.toString().indexOf(',');
	var fine = valore1.toString().substring(inizio);

	if (inizio > -1) {
		valore1 = valore1.substring(0, inizio);
		valore1 = replaceAll(valore1, ".", "");
		valore1 = valore1 + fine;
		valore1 = replaceAll(valore1, ",", ".");
	}

	inizio = valore2.indexOf(',');
	var fine = valore2.substring(inizio);

	if (inizio > -1) {
		valore2 = valore2.substring(0, inizio);
		valore2 = replaceAll(valore2, ".", "");
		valore2 = valore2 + fine;
		valore2 = replaceAll(valore2, ",", ".");
	}
	switch(op){
		case '+':
			valore = (parseFloat(valore1) + parseFloat(valore2)).toFixed(2);
			break;
		case '-':
			valore = (parseFloat(valore1) - parseFloat(valore2)).toFixed(2);
			break;
		case '/':
			valore = (parseFloat(valore1) / parseFloat(valore2)).toFixed(2);
			break;
		case '*':
			valore = (parseFloat(valore1) * parseFloat(valore2)).toFixed(2);
			break;
	}
	valore = valore.toString().replace('.', ',');
	
	valore = Formatta_NumSimpleValue(valore, 2, ",");

	return valore;
}

function replaceAll(entry, out, add) {
	while (entry.indexOf(out)>-1) {
		pos= entry.indexOf(out);
		entry = "" + (entry.substring(0, pos) + add + 
		entry.substring((pos + out.length), entry.length));
	}
	return entry;
}
    
    function Formatta_Num(val, dec, sep){
	//val = valore.value;
	val = replaceAll(val.toString(), '.', '');
	val = val.replace(',', '.');
	var segno = "";
	if (val.indexOf("-") > -1) {
		segno = "-";
	}
	if ((isNaN(val)) || (val.length == 0) || (val.substring(0, 1) == ",")) {
		val = 0;
	} else {
		s_val = new String(val);
		RE = /[^\d|\.,]/gi
		s_val = s_val.replace(RE,"");
		//RE = /\./gi;
		s_val = s_val.replace(RE,"");
		s_val = s_val.replace("\,","\.");
		a_val = s_val.split(".");
		intero=a_val[0];
		l_val = intero.length;
		var i = 3;
		while (l_val - 3 > 0){ 
			var l_val1 = intero.length; 
			var s1 = intero.slice( l_val1 - i , l_val1 ); 
			var s2 = intero.slice(0 , l_val1 - i ); 
			intero = s2+"."+s1; 
			i = i +4; 
			l_val = l_val - 3; 
		} 
		if(a_val.length>1) {
			s1 = String(a_val[1])
			while (s1.length<dec) {
				s1 = s1+"0";
			}
		} else { 
			s1 = "00"
		}
		val = segno + intero + sep + s1.substr(0, dec);
	}
	return val;
} 

function executeOp(valore1, valore2, op, ndec) {
	var valore;
	
	var inizio = valore1.toString().indexOf(',');
	var fine = valore1.toString().substring(inizio);

	if (inizio > -1) {
		valore1 = valore1.substring(0, inizio);
		valore1 = replaceAll(valore1, ".", "");
		valore1 = valore1 + fine;
		valore1 = replaceAll(valore1, ",", ".");
	}
	
	inizio = valore2.indexOf(',');
	var fine = valore2.substring(inizio);

	if (inizio > -1) {
		valore2 = valore2.substring(0, inizio);
		valore2 = replaceAll(valore2, ".", "");
		valore2 = valore2 + fine;
		valore2 = replaceAll(valore2, ",", ".");
	}
	
	if (valore1.length == 0) valore1 = "0";
	if (valore2.length == 0) valore2 = "0";

	switch(op){
			case '+':
				valore = (parseFloat(valore1) + parseFloat(valore2)).toFixed(ndec);
				break;
			case '-':
				valore = (parseFloat(valore1) - parseFloat(valore2)).toFixed(ndec);
				break;
			case '/':
				valore = (parseFloat(valore1) / parseFloat(valore2)).toFixed(ndec);
				break;
			case '*':
				valore = (parseFloat(valore1) * parseFloat(valore2)).toFixed(ndec);
				break;
		}
	
	valore = valore.toString().replace('.', ',');
	//valore = Formatta_Num(valore, 2, ",");
	
	return valore;
}
