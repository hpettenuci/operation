REGIONS="<region list with spaces>"
PROFILES="<aws cli profiles list with spaces>"

for PROFILE in $PROFILES; do
   for REGION in $REGIONS; do
      FUNCTIONS=$(aws lambda list-functions --region ${REGION} --profile ${PROFILE} | jq -r '.Functions[].FunctionName')
      for FUNCTION in $FUNCTIONS; do
         
         VERSIONS=vazio
         while [ "$VERSIONS" != '$LATEST' ]; do
            
            VERSIONS=$(aws lambda list-versions-by-function --function-name ${FUNCTION} --region ${REGION} --profile ${PROFILE} --no-paginate | jq -r '.Versions[].Version')
            for VERSION in $VERSIONS; do
               
               if [ "${VERSION}" != '$LATEST' ]; then
                  echo "Deleted ${PROFILE} -> ${REGION} -> ${FUNCTION}:${VERSION}"
                  aws lambda delete-function --function-name ${FUNCTION}:${VERSION} --region ${REGION} --profile ${PROFILE}
               fi
            done
         done
      done
   done
done
