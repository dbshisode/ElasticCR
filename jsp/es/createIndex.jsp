<%@ page import="com.dee.ESIndex" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
</head>
<body>
<%
    if (request.getParameter("subForm")!=null && request.getParameter("subForm").equals("sub")){
        //call ESIndex.execute() to create Index
        int retCode = ESIndex.execute();
    }
%>
<div>
    <div style="min-height: 100px;float: left;margin: 10%;vertical-align: middle;width: 80%;">
        <form action="createIndex.jsp" method="post">

            <input type="hidden" name="subForm" value="sub"><br>
            Please click <input type="submit" value="Create"> to create an Index.
        </form>
    </div>
</div>

</div>
</body>
</html>
