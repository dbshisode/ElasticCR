<%@ page import="org.json.JSONArray" %>
<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>

<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">
<%--<script src="../../js/jquery.twbsPagination.js"></script>--%>
<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>

<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
<link rel="stylesheet" href="/resources/demos/style.css">
<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
<script src="../../js/jquery.twbsPagination.min.js"></script>
<%
    JSONArray toshibaResultsJArray = new JSONArray();
%>
<script type="text/javascript" src="../../js/elasticsearch.js"></script>
<script language="JavaScript">

// var elasticsearch = require('elasticsearch');
var search_response;
var hits;
var client = new elasticsearch.Client({
    host: '127.0.0.1:9200',
    log: 'trace'
});
client.search({
    index: 'products',
    type: 'info',
    body: {
        "size" : 0,
        "aggregations": {
            "tags": {
                "terms": {"field": "tagsList.keyword","size" : 25},
                "aggregations": {
                    "significantTags": {
                        "significant_terms": {"field": "tagsList.keyword"}
                    }
                }
            }
        }
    }
}).then(function (resp) {
            search_response = resp;
            var aggregs = resp.aggregations.tags.buckets;
            var stStr;
            for(i = 0; i < aggregs.length; i++)
            {
                var item = aggregs[i];
                $('#facetsDiv').append('<div style="margin-left:20px ;"><label><input type="checkbox" class="tagsClass" onclick="loadDocs(\''+item.key+'\',\'tags\');" id="'+item.key+'" name="'+item.key+'">'+item.key+'</label></div>');
            }
            $('#facetsDiv').append('</div>');
        }, function (err) {
            console.trace(err.message);
        });


var availableTags = [];
$( function() {
    //var availableModels = [];
    $( "#searchModel" ).autocomplete({
        source: availableTags
    });
} );

function ElaSuggester(){
    client.search({
        index: "products",
        type: "info",
        body: {
            "_source": ["text"],
            "suggest": {
                "prodsuggest" : {
                    "text" : $('#searchModel').val(),
                    "completion" : {
                        "field" : "product_family_suggest"
                    }
                }
            }
        }
    }).then(function (resp) {
                for(i = 0; i < resp.suggest.prodsuggest[0].options.length; i++){
                    availableTags[i] = resp.suggest.prodsuggest[0].options[i].text;
                }
            });
}
function searchIndex(field){
    var fieldnames = ["synopsis","specifications"];
    var query = $('#searchField').val();
    if (field == 'product_family'){
        fieldnames = ["product_family"];
        query = $('#searchModel').val();
    }
    client.search({
        index: 'products',
        type: 'info',
        body: {
            size : 25,
            "_source": ["productname","specifications","synopsis","img"],
            "query": {
                "query_string": {
                    "query": query,
                    //"fields": ["attachment.content","supportContent"]
                    "fields":fieldnames
                }
            }
        }
    }).then(function (resp) {
                $('#searchResultsDiv').empty();
                search_response = resp;
                hits = search_response.hits.hits;
                if(hits.length){
                //alert(hits.length);
                    paginationHits(hits);
                }else{
                    $('#searchResultsDiv').append('<h3>Sorry, No Results Found.</h3>');
                }
}, function (err) {
                console.trace(err.message);
            });
}
function loadDocs(tag,type){
    var total=$(this).find('input[name="tagsClass[]"]:checked').length;
    var i = 0;
    var selected = $('input:checkbox:checked.tagsClass').map(function () {
        //alert(i+1);
        //return this.name+' OR ';
        return this.name;
    }).get();
    var stringyfyselect = JSON.stringify(selected);

    var fieldsVar;
    var fieldsName;
    if(type == 'tags'){
        fieldsVar = selected;
        fieldsName = 'tagsList'
    }

    client.search({
        index: 'products',
        type: 'info',
        body: {
            size : 50,
            "_source": ["productname","specifications","synopsis","img"],
            query: {
                "bool": {
                    "must": {
                        "multi_match": {
                            "fields": [fieldsName],"query": JSON.stringify(fieldsVar)
                            //"type":"phrase"
                            //JSON.stringify(fieldsVar)
                        }
                    },
                    "filter":{
                        /*                        "match_phrase": {
                         tagsList :   ["Driver","Toshiba"]
                         //"tagsList": ["Driver","Toshiba"]
                         }*/
                    }
                }
            }
        }
    }).then(function (resp) {
                $('#searchResultsDiv').empty();
                search_response = resp;
                hits = search_response.hits.hits;
                if (hits.length > 0) {
                //alert(hits.length);
                paginationHits(hits);
                }else{
                    $('#searchResultsDiv').append('<h3>Sorry, No Results Found.</h3>');
                }
            }, function (err) {
                console.trace(err.message);
            });

}
function paginationHits(hits){
    var totPages;
    if (hits.length%5 == 0)
        totPages = hits.length/5;
    else
        totPages = Math.floor(hits.length/5)+1;
    //alert('totPages:'+totPages);
    $('#pagination').twbsPagination('destroy');
    $('#pagination').twbsPagination({
        totalPages: totPages,
        visiblePages: 6,
        next: 'Next',
        prev: 'Prev',
        onPageClick: function (event, page) {
            //render
            pageDisplay(page,hits.length);
        }
    });
}

function pageDisplay(pageNo,totRes){
    //alert(totRes);
    var startCnt = 0;
    var endCnt = 0;
    if (totRes > 5){
        if (pageNo == 1){
            startCnt = 0;
            endCnt = 5;
        } else {
            startCnt = (pageNo - 1)*5;
            endCnt = (pageNo * 5 < totRes)? startCnt + 5 : startCnt + totRes%5;
        }
    } else {
        startCnt = 0;
        endCnt = totRes;
    }
    $('#searchResultsDiv').empty();
    var array = [];
    array.push('<div>');
    array.push('<div><h4>Results ('+hits.length+')</h4></div>');
    for(i = startCnt; i < endCnt; i++)
    {
        var item = search_response.hits.hits[i];
        array.push('<div style="float:left;clear: left;>');
        array.push('<div style="float:left;width:20%;"><img src="'+item._source.img+'"></div><div style="float:left;width:5%;">&nbsp;</div>');
        //$('#searchResultsDiv').append('<div style="float:left;">');
        array.push('<div style="float:left;width: 75%;margin-bottom: 10px;"><div style="float:left;font-weight:12px;color: #FF5500;padding-bottom: 0px;padding-top: 8px;">');
        array.push(item._source.productname);
        array.push('</div><div style="float:left;clear: left;"><a href="#"> '+item._source.specifications+'</a>');
        array.push('</div><div style="float:left;clear: left;">'+item._source.synopsis);
        //$('#searchResultsDiv').append('</div>');
        array.push('</div></div></div>');
    }
    array.push('</div>');
    $("#searchResultsDiv").append(array.join(''));
}

</script>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Elastic Search</title>
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body>
<div>
    <div style="min-height: 100px;float: left;text-align: center;vertical-align: middle;width: 80%;">
        <div style="margin-top: 20px;margin-left: 20px;float: left"><img src="../../images/shop_icon.jpg"></div>
        <div style="margin-top: 20px;width: 100%;">
            <form name="searchF" id="searchF">
                <div>

                    <div style="float: left;margin: 10px;width: 40%;">
                        <input name="searchField" id="searchField" type="text" size="20">&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="Search Products" onclick="searchIndex();">
                    </div>
                    <div style="float: left;margin: 10px;width: 30%;">
                        <input name="searchModel" size="20" id="searchModel" type="text" placeholder="Autocomplete" onkeyup="ElaSuggester();">&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="Search" onclick="searchIndex('product_family');">
                    </div>
                </div>
            </form>
        </div>
    </div>
    <div style="float: left;clear: left;">
        <div id="facetsDiv" style="float: left; margin-left: 20px;border-spacing: 10px 50px;min-width: 240px; "><h4 style="color: #960000;font-weight: bold; ">&nbsp;Filter By:</h4></div>
        <div style="float: right;border-top: 1px solid #AA0000;width: 1000px;border-left: 1px solid #AA0000;min-height: 700px;">
            <div style="float: left;margin-left: 30px;">
                <div id="pagination" class="pagination" style="float: left;"></div>
                <div id="searchResultsDiv" class="pagination" style="clear:left;float: left;">
                    <h3>Please Enter/Select Search Criteria</h3>
                </div>
            </div>
        </div>
    </div>
</div>

</div>
</body>
</html>
