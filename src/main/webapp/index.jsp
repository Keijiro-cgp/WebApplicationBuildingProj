<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.net.*"%>
<%!
String debug_log = "";

class Member {
	double num = 0;
	char ope = '0';
	Member right;
	Member head;
	
	void set_num(double n) {
		num = (num * 10) + n;
	}
	
	void set_ope(char o) {
		if(ope == '0') {
			ope = o;
		}
	}
	
	double get_num() {
		if(head == null) {
			return num;
		} else {
			return calculate(head);
		}
	}
	
	double get_right_num() {
		if(right.ope == '^') {
			return power(right.get_num(), right.get_right_num());
		} else {
			return right.get_num();
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
	int n, num = 0, shift = 0;
	n = text.length();
	Member m;
	m = head;
	for (int i=0; i<n; i++) {
		debug_log += "loop:" + i + "<br>";
		char c = text.charAt(i);
		debug_log += "read: " + c + "<br>";
		if(c != ' ') {
			if('0' <= c && c <= '9') {
				m.set_num((double)(c - '0'));
				result += c;
			} else if (c == '+' || c == '-' || c == '*' || c == '/' || c == '^') {
				m.set_ope(c);
				result += c;
			} else if (c == '.') {
				result += c;
				char c2 = text.charAt(i + 1);
				while ('0' <= c2 && c2 <= '9') {
					shift++;
					if(i + shift + 1 >= n) break;
					c2 = text.charAt(i + shift + 1);
				}
				debug_log += "shift = " + shift + "<br>";
			} else if (c == '(') {
				result += c;
				Member m2 = new Member();
				String s = "";
				i++;
				while(true) {
					c = text.charAt(i);
					s += c;
					result += c;
					if(c == ')') break;
					i++;
				}
				check_text(s, m2);
				m.head = m2;
			} else {
				result = "error:入力に無効な文字が含まれています。";
				break;
			}
			if(m.ope != '0') {
				debug_log += "10 ^ shift:" + power(10, shift) + ", m.num:";
				m.num /= power(10, shift);
				debug_log += m.num / power(10, shift) + "<br>";
				shift = 0;
				Member tmp = new Member();
				m.right = tmp;
				m = tmp;
			}
		}
	}
	debug_log += "10 ^ shift:" + power(10, shift) + ", m.num:";
	m.num /= power(10, shift);
	debug_log += m.num / power(10, shift) + "<br>";
	shift = 0;
	return result;
}

String print_member(Member head) {
	String result = "";
	Member m = head;
	do {
		result += "(" + m.get_num() + " " + m.ope + ")";
		m = m.right;
	} while(m != null);
	return result;
}

double calculate(Member m) {
	double result = 0;
	ArrayList<Double> n = new ArrayList<>();
	double r = 0;
	int i = 0;
	while(m.right != null) {
		if(m.ope == '+') {
			if(n.size() == 0) {
				debug_log += "add: " + m.get_num() + "<br>";
				n.add(m.get_num());
				i++;
			}
			debug_log += "add: " + m.right.get_num() + "<br>";
			n.add(m.get_right_num());
			i++;
		} else if(m.ope == '-') {
			if(n.size() == 0) {
				debug_log += "sub: " + m.get_num() + "<br>";
				n.add(m.get_num());
				i++;
			}
			double d = 0;
			d = m.get_right_num() * -1;
			debug_log += "sub: " + d + "<br>";
			n.add(d);
			i++;
		} else if(m.ope == '*') {
			if(n.size() == 0) {
				debug_log += "mul: " + m.get_num() + " * " + m.get_right_num() + "<br>";
				n.add(m.get_num() * m.get_right_num());
				i++;
			} else {
				debug_log += "mul: " + n.get(i-1) + " * " + m.get_right_num() + "<br>";
				n.set(i-1, n.get(i-1) * m.get_right_num());
			}
		} else if (m.ope == '/') {
			if(n.size() == 0) {
				debug_log += "div: " + m.get_num() + " / " + m.get_right_num() + "<br>";
				n.add(m.get_num() / m.get_right_num());
				i++;
			} else {
				debug_log += "div: " + n.get(i-1) + " / " + m.get_right_num() + "<br>";
				n.set(i-1, n.get(i-1) / m.get_right_num());
			}
		} else if (m.ope == '^') {
			if(n.size() == 0) {
				debug_log += "pow: " + m.get_num() + " ^ " + m.get_right_num() + "<br>";
				n.add(power(m.get_num(), m.get_right_num()));
				i++;
			} else {
				//何もしない
			}
		}
		m = m.right;
	}
	debug_log += "size: " + n.size() + "<br>";
	for (int k=0; k<n.size(); k++) {
		debug_log += "r = " + r + "<br>";
		r += n.get(k);
	}
	result = r;
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
	result = prettyPrintHTML(Double.valueOf(calculate(m)).toString());
	debug_txt = prettyPrintHTML(print_member(m));
}

%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>簡数電卓</title>
</head>
<body>
<h1>Welcome to 簡数電卓!</h1>
<form action="index.jsp" method="get">
	<input type="text" name="text" size="40">
	<input type="submit" value="計算">
</form>
<p>計算結果 = <%= result %></p>
<h2>//使い方//</h2><br>
<p>
	四則演算(+ - * /)と累乗(^)、カッコ付きの計算ができます。<br>
	テキストボックスに計算式を入力し、「計算」ボタンを押せば「計算結果 = 」の横に計算結果が表示されます。
</p>
<p>入力文字列 = <%= msg %></p>
<p><%= debug_txt %></p>
///Debug log///
<p><%= debug_log %></p>
</body>
</html>