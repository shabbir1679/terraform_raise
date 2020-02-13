import groovy.json.JsonSlurper
import groovy.json.* 
REPO = "tcs-pega"
def nexusAPIResponse = new URL("https://restore-nexus.tools.tsys.aws/service/rest/v1/components?repository=${REPO}").text;
def nexusAPISlurper = new JsonSlurper()
def nexusAPIResponseSlurper = nexusAPISlurper.parseText(nexusAPIResponse)
def continuationToken = nexusAPIResponseSlurper.continuationToken
 
println "continuationToken: "+continuationToken
println 'nexusAPIResponseSlurper: '+nexusAPIResponseSlurper.items.version.size()
println "--------------------------------"
 
try {
while(continuationToken != 'null'){
def nexusAPIResponseWithToken = new URL("https://restore-nexus.tools.tsys.aws/service/rest/v1/components?continuationToken=${continuationToken}&repository=${REPO}").text;
def nexusAPISlurperWithToken = new JsonSlurper()
def dockeAPIResponseSlurper = nexusAPISlurperWithToken.parseText(nexusAPIResponseWithToken)
def json = dockeAPIResponseSlurper
def js4 = new JsonBuilder(json).toPrettyString()
println js4.toString()
def nexusAPIResponseSlurperWithToken = nexusAPISlurperWithToken.parseText(nexusAPIResponseWithToken)
continuationToken = nexusAPIResponseSlurperWithToken.continuationToken
 
println "loopContinuationToken: "+continuationToken
println 'loopNexusAPIResponseSlurperWithToken: '+nexusAPIResponseSlurperWithToken.items.version.size()
println "--------------------------------"
continuationToken = nexusAPIResponseSlurperWithToken.continuationToken
}
}
catch(IOException ex) {
println "--------------------------------"
}

