include config.mk

ORG_ID=ocd-organization/0f63aae8-16fd-4d3c-b525-00747a482cf9

all : abstentions.csv

ocd_ctrl_socket :
	ssh -M -S $@ -fnNT -L $(PG_PORT):localhost:5432 ubuntu@ocd.datamade.us

.PHONY : clean
clean : ocd_ctrl_socket
	ssh -S $^ -O exit ubuntu@ocd.datamade.us

abstentions.csv : ocd_ctrl_socket
	psql -h $(PG_HOST) -p $(PG_PORT) -d $(PG_DB) -U $(PG_USER) -c \
	"COPY ( \
             SELECT voter_name AS voter, \
                    opencivicdata_bill.identifier AS identifier, \
                    option, motion_text, start_date \
             FROM \
	     opencivicdata_personvote \
             INNER JOIN opencivicdata_voteevent \
	         ON vote_event_id=opencivicdata_voteevent.id \
	     INNER JOIN opencivicdata_bill \
	         ON bill_id = opencivicdata_bill.id \
             WHERE option!='yes' AND option!='no' \
                   AND organization_id='$(ORG_ID)') \
          TO STDOUT WITH CSV HEADER" | python slugify.py > $@
