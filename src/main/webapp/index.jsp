<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.net.*"%>
<%!
String debug_log = "";

class Member {
	double num = 0;
	char ope = '0';
	Member right;
	
	void set_num(double n) {
		int i = 0;
		num = (num * 10) + n;
	}
	
	void set_ope(char o) {
		if(ope == '0') {
			ope = o;
		}
	}
}

String prettyPrintHTML(String s) {
	if (s == null)
		return "";
	return s.replace("&", "&amp;")
			.replace("\"", "&quot;")
			.replace("<", "&lt;")
			.replace(">", "&gt;")
			.replace("'", "&#39;")
			.replace("\n", "<br>\n");
}

public class MyHttpClient {
	public String url = "https://www.debian.org/"; /* URL */
	public String encoding = "UTF-8"; /* レスポンスの文字コード */
	public String header = ""; /* レスポンスヘッダ文字列 */
	public String body = ""; /* レスポンスボディ */

	/* 2つの引数（URL，エンコーディング）をとるコンストラクタ */
	public MyHttpClient(String url_, String encoding_) {
		url = url_;
		encoding = encoding_;
	}

	/* 1つの引数（URL）をとるコンストラクタ */
	public MyHttpClient(String url_) {
		url = url_;
	}

	/* 実際にアクセスし，フィールドheaderおよびbodyに値を格納する */
	public void doAccess()
	throws MalformedURLException, ProtocolException, IOException {

		/* 接続準備 */
		URL u = new URL(url);
		HttpURLConnection con = (HttpURLConnection)u.openConnection();
		con.setRequestMethod("GET");
		con.setInstanceFollowRedirects(true);

		/* 接続 */
		con.connect();

		/* レスポンスヘッダの獲得 */
		Map<String, List<String>> headers = con.getHeaderFields();
		StringBuilder sb = new StringBuilder();
		Iterator<String> it = headers.keySet().iterator();

		while (it.hasNext()) {
			String key = (String) it.next();
			sb.append("  " + key + ": " + headers.get(key) + "\n");
		}

		/* レスポンスコードとメッセージ */
		sb.append("RESPONSE CODE [" + con.getResponseCode() + "]\n");
		sb.append("RESPONSE MESSAGE [" + con.getResponseMessage() + "]\n");

		header = sb.toString();

		/* レスポンスボディの獲得 */
		BufferedReader reader = new BufferedReader(
			new InputStreamReader(con.getInputStream(),
				encoding));
		String line;
		sb = new StringBuilder();

		while ((line = reader.readLine()) != null) {
			sb.append(line + "\n");
		}

		body = sb.toString();

		/* 接続終了 */
		reader.close();
		con.disconnect();
	}
}

String check_text(String text, Member head) {
	String result = "";
	int n, num = 0, ope = 0;
	n = text.length();
	Member m;
	m = head;
	for (int i=0; i<n; i++) {
		debug_log += "loop:" + i + "<br>";
		char c = text.charAt(i);
		if(c != ' ') {
			if('0' <= c && c <= '9') {
				m.set_num((double)(c - '0'));
				result += c;
			} else if (c == '+' || c == '-' || c == '*' || c == '/' || c == '^' || c == 'r' || c == 'l' || c == 's' || c == 'c' || c == 't') {
				m.set_ope(c);
				result += c;
			} else {
				result = "error:入力に無効な文字が含まれています。";
				break;
			}
			if(m.ope != '0') {
				debug_log += "num:" + m.num + ", ope:" + m.ope + "<br>";
				Member tmp = new Member();
				m.right = tmp;
				m = tmp;
			}
		}
		
	}
	return result;
}

String print_member(Member head) {
	String result = "";
	Member m = head;
	do {
		result += "(" + m.num + " " + m.ope + ")";
		m = m.right;
	} while(m != null);
	return result;
}

String calculate(Member m) {
	String result = "";
	double n;
	n = m.num;
	while(m.right != null) {
		switch(m.ope) {
		case '+': n = add(n, m.right.num); break;
		case '-': n = subtract(n, m.right.num); break;
		case '*': n = multiply(n, m.right.num); break;
		case '/': n = divide(n, m.right.num); break;
		case '^': n = power(n,m.right.num); break;
		case 'r': n = root(n); break;
		case 'l': n = log(n); break;
		case 's': n = sin(n); break;
		case 'c': n = cos(n); break;
		case 't': n = tan(n); break;
		default: result = "error"; break;
		}
		m = m.right;
	}
	result = Double.valueOf(n).toString();
	return result;
}

//足し算
double add(double a, double b) {
	return a + b;
}
//引き算
double subtract(double a, double b) {
	return a - b;
}
//掛け算
double multiply(double a, double b) {
	return a * b;
}
//割り算
double divide(double a, double b) {
	return a / b;
}
//累乗
double power(double a, double b){
	double n = 1;
	while(b != 0){
		n = n * a;
		--b;
	}
	return n;
}
//平方根
double root(double a){
	double n = Math.sqrt(a);
	return n;
}
//自然対数
double log(double a){
	double n = Math.log(a);
	return n;
}
//sin関数
double sin(double a){
	//度からラジアンに変換
	double radian = Math.toRadians(a);
	double n = Math.sin(radian);
	return n;
}
//cos関数
double cos(double a){
	//度からラジアンに変換
	double radian = Math.toRadians(a);
	double n = Math.cos(radian);
	return n;
}
//tan関数
double tan(double a){
	//度からラジアンに変換
	double radian = Math.toRadians(a);
	double n = Math.tan(radian);
	return n;
}
%>
<%
//リクエスト・レスポンスとも文字コードをUTF-8に
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

String msg = ""; // 結果メッセージ
MyHttpClient mhc; // HTTPで通信するためのインスタンス

boolean optionEscape = ("1".equals(request.getParameter("E"))); // レスポンスボディをHTMLエスケープするならtrue

String text = request.getParameter("text");
Member m = new Member();
String result = "";
String debug_txt = "";

if (text != null) {
	msg = prettyPrintHTML(check_text(text, m));
	result = prettyPrintHTML(calculate(m));
	debug_txt = print_member(m);
}

%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Hello!</title>
</head>
<body>
<h1>Hello World!</h1>
<form action="index.jsp" method="get">
	<input type="text" name="text" size="40">
	<input type="submit">
</form>
<p><%= msg %></p>
<p>result = <%= result %></p>
<p><%= debug_txt %></p>
///Debug log///
<p><%= debug_log %></p>
</body>
</html>