<%@ page language="java"%>
<%@ page pageEncoding="UTF-8" contentType="text/html;charset=utf-8"%>
<!DOCTYPE html>
<%@taglib uri="/struts-tags" prefix="s"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Hello World</title>
</head>
<body>
	<h1>${user.username}</h1>
	<h1>${user.name}</h1>
	<h1>${user.password}</h1>
	<s:form action="helloSave">
		<s:textfield name="user.name" label="User Name" />
		<s:submit />
	</s:form>
</body>
</html>
