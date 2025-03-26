<template>
	<div>
		<h3>Create packages</h3>
	</div>
	<div>
		<v-card class="col-12 col-md-9 col-lg-9 ma-auto">
    <v-card-title class="v-card-title-uppercase">{{
      t("filmDocuments.create")
    }}</v-card-title>

    <Form @submit="submitFilmDocData" ref="filmDocumentForm">
      <v-container>
        <v-row>

		</v-row>
        <v-row class="mt-3">
          <v-col class="d-flex justify-content-center">
            <v-btn type="submit">{{ t("common.save") }}</v-btn>
            <v-divider vertical></v-divider>
            <v-btn class="cancel">{{ t("common.cancel") }}</v-btn>
          </v-col>
        </v-row>
      </v-container>
    </Form>
  </v-card>
	</div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'

export default defineComponent({
	setup () {
		

		return {}
	}
})
</script>

<style lang="scss" scoped>

@import "@/assets/styles/display-create-edit.scss"

</style>